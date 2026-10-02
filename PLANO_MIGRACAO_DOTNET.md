# Plano de migração: NfeServer Delphi → C# (.NET + Zeus DFe.NET)

Branch: `feature/migracao-dotnet-zeus` · Última atualização: 02/10/2026

Este documento registra a decisão, o que já foi feito, os bugs corrigidos, o que mudou no contrato
e o que falta para colocar o servidor .NET em produção no lugar do serviço Delphi.

> O código Delphi foi **removido deste branch**. Para consultar a implementação original, use o
> commit `d36ff14` do `master` (`git show d36ff14:services/dfe.services.validar.pas`, por exemplo).
> Neste documento, os caminhos `*.pas` se referem a esse commit.

---

## 1. Decisão

| Item | Antes (Delphi) | Agora (.NET) |
|---|---|---|
| Linguagem/runtime | Delphi (VCL `TService`) | C# 12, .NET 8 (LTS) |
| HTTP | Indy `TIdHTTPServer`, roteamento manual | ASP.NET Core (Kestrel), controllers |
| Biblioteca fiscal | ACBrNFe | **Zeus DFe.NET** (`Zeus.Net.NFe.NFCe` 2026.9.24) |
| DANFE | Fortes Report (`TACBrNFeDANFeRL`) | `Zeus.Net.NFe.Danfe.PdfClown` (NF-e A4) e `Zeus.Net.NFe.Danfe.QuestPdf` (NFC-e e CC-e) |
| Banco | MongoDB via FireDAC | MongoDB via `MongoDB.Driver` 3.x, **mesmas coleções e campos** |
| Arquitetura | handler → controller → service → DAO, estado compartilhado | Clean Architecture (Domain / Application / Infrastructure / Api) |
| Hospedagem | Serviço Windows | Serviço Windows (`UseWindowsService`) ou console; roda também em Linux/Docker |

**Por que Zeus:** é 100% gerenciado (sem DLL nativa nem OpenSSL), open source (LGPL), cobre NF-e e
NFC-e e está atualizado com a reforma tributária (campos IBS/CBS e eventos novos). O preço é ter
que portar as regras que o ACBr fazia sozinho. Essas regras estão na seção 4.

## 2. Arquitetura

```
src/
├─ NfeServer.Domain          regras puras, sem dependências
│    Entidades/   Empresa, NotaFiscal, Cancelamento, CartaCorrecao, Inutilizacao, ResumoDashboard
│    Fiscal/      ChaveAcesso (DV, CNPJ alfanumérico), Cnpj, Uf, ContingenciaSvc, Justificativa
│    Comum/       CodigosRetorno (cStat), RegraNegocioException
├─ NfeServer.Application     casos de uso + portas
│    Abstracoes/  ISefazNFeGateway, IDanfeService, ICertificadoInspector, repositórios
│    CasosDeUso/  AutorizarNotaFiscal, CancelarNotaFiscal, EmitirCartaCorrecao,
│                 InutilizarNumeracao, GerenciarEmpresas, ConsultarDocumentos
│    Consultas/   FiltroConsulta (lista branca de campos)
├─ NfeServer.Infrastructure  adaptadores
│    Fiscal/      ZeusSefazNFeGateway, ConfiguracaoZeus, XmlFiscal
│    Pdf/         DanfeService
│    Certificados/ ProvedorCertificados (cache em memória), InspetorCertificado
│    Persistencia/Mongo/ mapeamento compatível com o Delphi, repositórios, dashboard
│    Seguranca/   ProtetorSegredos (Data Protection), OpcoesSeguranca
└─ NfeServer.Api             ASP.NET Core
     Legado/      /dfeapi/* com o contrato JSON do Delphi
     V2/          /api/v2/* (REST novo)
     Infra/       ApiKeyMiddleware
     wwwroot/     front-end original (jQuery/Color Admin), servido como arquivo estático
tests/NfeServer.UnitTests
```

Regra de dependência: `Api → Infrastructure → Application → Domain`. Nenhum tipo do Zeus ou do MongoDB
aparece em Application ou Domain. A porta `ISefazNFeGateway` trafega XML em string, então a
biblioteca fiscal pode ser trocada (ACBrLib, Unimake) sem mexer nos casos de uso.

### Onde foi parar cada unit Delphi

| Delphi (`d36ff14`) | .NET |
|---|---|
| `httpserver/*`, `httphandlers/*` | `Api/Legado/DfeApiControllers.cs`, `ControllerLegadoBase.cs` |
| `controller/nfe.controller.*` | `Api/Legado/MapeamentoLegado.cs` + casos de uso |
| `services/dfe.services.validar.pas` | `Application/CasosDeUso/AutorizarNotaFiscal.cs` + `ZeusSefazNFeGateway.Preparar/Autorizar/ConsultarProtocolo` |
| `services/dfe.services.cancelar.pas` | `CancelarNotaFiscal.cs` + `ZeusSefazNFeGateway.Cancelar` |
| `services/dfe.services.cartaCorrecao.pas` | `EmitirCartaCorrecao.cs` |
| `services/dfe.services.inutilizar.pas` | `InutilizarNumeracao.cs` |
| `lib/dfe.lib.acbr.config.pas` | `ConfiguracaoZeus.cs`, `ProvedorCertificados.cs` |
| `dao/*` | `Infrastructure/Persistencia/Mongo/*` |
| `model/*`, `model/request/*` | `Domain/Entidades/*`, `Api/Legado/ModelosLegados.cs` |
| `win32service/*` | `Program.cs` (`UseWindowsService`) |
| `lib/dfe.lib.jsontoXml.pas`, `xmltoJson.pas`, `databinding/*` | removidos (só o app de teste `consumer` usava) |
| `schedule/dfe.schedule.importacaopdv.pas` | removido (referenciava units `rps.*` inexistentes; código morto) |
| `consumer/` (app VCL de teste) | substituído pelo Swagger em Development |
| `bin/web/template` | `src/NfeServer.Api/wwwroot` |

## 3. Status

### Concluído neste branch

- [x] Solution .NET 8 com as 4 camadas e o projeto de testes
- [x] Autorização NF-e/NFC-e: síncrona e assíncrona (SP e BA, configurável), consulta de recibo, duplicidade 204/539, nfeProc, DANFE
- [x] Contingência SVC-AN/SVC-RS manual, com recálculo da chave
- [x] QR Code da NFC-e com CSC/IdCSC (campos novos na empresa)
- [x] Cancelamento (com retry no 577), carta de correção, inutilização
- [x] CRUD de empresa com validação do PFX e da senha; validade lida do certificado
- [x] Listagens e dashboard
- [x] API legada `/dfeapi/*` com o mesmo JSON do Delphi (`listHelper`, datas, nomes de campo)
- [x] API REST v2 `/api/v2/*` com Swagger
- [x] Persistência compatível com os documentos já gravados pelo Delphi
- [x] Front-end servido pela API, com `_HOST` relativo
- [x] Serilog (console + arquivo diário), health check `/health`, compressão de resposta
- [x] 46 testes passando: domínio, contrato legado, casos de uso e Zeus offline (assinatura válida no nfeProc, contingência, DANFE A4)
- [x] Remoção de todo o código, binários, DLLs e certificados do Delphi deste branch

### Pendente (por fase)

**Fase 1: homologação (antes de qualquer produção)**
- [ ] Subir MongoDB local e testar a leitura de documentos reais gravados pelo Delphi (datas, inteiros, `listHelper` no front). *Nesta máquina não havia MongoDB, então a persistência não foi testada ponta a ponta.*
- [ ] Emitir em homologação, com certificado A1 válido: NF-e síncrona (ex.: MG/PR), NF-e assíncrona (SP), NFC-e, cancelamento, CC-e e inutilização
- [ ] Forçar uma duplicidade 204 (reenviar uma nota autorizada) e conferir a recuperação do protocolo
- [ ] Testar a contingência SVC com `contigencia = 1`
- [ ] Baixar o pacote de schemas do PL vigente (NT da reforma tributária) e apontar `Sefaz:DiretorioSchemas`. Os XSD do Delphi eram de 2021 e foram removidos.
- [ ] Confirmar com a NT vigente a versão do QR Code da NFC-e (`Sefaz:VersaoQrCodeNfce`, padrão 2) e a tabela de UFs do SVC (`ContingenciaSvc.cs`)
- [ ] Gravar uma requisição real de cada PDV/cliente e comparar a resposta do Delphi com a do .NET campo a campo

**Fase 2: segurança**
- [ ] **Revogar/trocar os certificados que estavam versionados** (`bin/certficados/*.pfx`, um deles com a senha no nome do arquivo). Apagar os arquivos não os remove do histórico do git nem do GitHub. Avaliar `git filter-repo` + force push (decisão do responsável pelo repositório).
- [ ] Configurar `Seguranca:ApiKeys` e distribuir as chaves aos clientes (cabeçalho `X-Api-Key`). O front-end precisa enviar o cabeçalho ou ficar atrás de login.
- [ ] Depois de desligar o Delphi: `Seguranca:ProtegerSegredosNoBanco = true` (a senha do PFX e o CSC passam a ser criptografados com Data Protection/DPAPI) e regravar as empresas
- [ ] HTTPS no Kestrel (certificado do servidor) ou proxy reverso

**Fase 3: convivência e virada**
- [ ] Publicar o .NET em outra porta (ex.: 4476) apontando para o **mesmo** `nfeDb`; o formato de gravação é compatível nos dois sentidos
- [ ] Migrar os clientes um a um para a nova porta e monitorar os logs (`logs/nfeserver-*.log`)
- [ ] Desligar o serviço Delphi e trocar o .NET para a porta 4475

**Fase 4: evolução**
- [ ] Atualizar para **.NET 10 LTS**: o suporte do .NET 8 termina em 10/11/2026. É só trocar `TargetFramework` e instalar o SDK 10.
- [ ] Migrar as datas no Mongo de string para `BsonDateTime` quando o Delphi não ler mais o banco (`DataLegadaSerializer` já lê os dois formatos)
- [ ] Clientes migrando para `/api/v2`; depois, deprecar `/dfeapi`
- [ ] Trava por chave de acesso contra envio simultâneo da mesma nota (hoje a duplicidade 204 já recupera o resultado)
- [ ] Mover o DANFE do Mongo para arquivo ou storage (cada nota guarda o PDF em base64, herança do Delphi)
- [ ] Testes de integração com MongoDB em container (Testcontainers)

## 4. Bugs do Delphi e como ficaram

| # | Problema no Delphi | Onde (`d36ff14`) | Correção |
|---|---|---|---|
| 1 | **Requisições simultâneas misturavam respostas**: `Context`, `RequestInfo`, `ResponseInfo` e `jValue` ficavam em campos de uma instância única, compartilhada pelas threads do Indy | `httpserver/dfe.httpserver.pas` (`updateSubclass`) | Controllers e casos de uso por requisição (DI scoped) |
| 2 | **Roteamento sobreposto**: os 6 handlers rodavam em toda requisição; `/dfeapi/nfe` casava por prefixo com `/nfe/info` e `/nfe/empresa` | `httphandlers/dfe.httphandler.nfe.pas` | Rotas exatas por atributo |
| 3 | **Certificados versionados no git**, um com a senha no nome do arquivo | `bin/certficados/` | Removidos; `*.pfx` no `.gitignore`. Rotação pendente (Fase 2) |
| 4 | **PFX regravado em disco a cada requisição**, com nome fixo (disputa entre requisições da mesma empresa) | `lib/dfe.lib.acbr.config.pas` | Certificado carregado em memória e cacheado por empresa |
| 5 | **GET de empresa devolvia o PFX e a senha** a qualquer chamador | `dao/dfe.dao.empresa.pas` | Listagens nunca devolvem PFX, senha nem CSC; gravação sem esses campos mantém os atuais |
| 6 | **Injeção no MongoDB**: o JSON da query string ia direto para `Match()` | todos os `dao/*.listXxx` | `FiltroConsulta` com lista branca de campos e só valores escalares |
| 7 | **Checagem de nota já autorizada nunca funcionava**: buscava por `ambiente` (duas vezes), campo que a nota não tem | `dfe.services.validar.pas` (construtor) | Busca pela chave de acesso |
| 8 | **Duplicidade 204 não era gravada**, então todo reenvio repetia o ciclo | `dfe.services.validar.pas` (`validar`) | Upsert pela chave sempre que houve envio |
| 9 | **Rejeição 539 (cNF diferente) virava "autorizada"** com um XML que não era o autorizado | `consultaChave` | Mantém a rejeição e informa a chave/protocolo encontrados; não monta nfeProc inválido |
| 10 | **Cancelamento inventava protocolo** (`FormatDateTime('yymmddhhmmsszz')`) quando a SEFAZ não devolvia | `dfe.services.cancelar.pas` | Removido |
| 11 | **dhEvento do cancelamento era só a data** (meia-noite), quase sempre rejeitado com 577 | `dfe.services.cancelar.pas` | Usa a data/hora informada só se tiver hora e não estiver no futuro; senão, agora. Mantido o retry no 577 |
| 12 | **Nota não era marcada como cancelada**, e o dashboard nunca mostrava canceladas | `dao/dfe.dao.infoNfe.pas` | `MarcarCanceladaAsync` + dashboard lê os cancelamentos aceitos |
| 13 | **NFC-e com `ModeloDF := moNFe` fixo** e sem CSC: QR Code e URL de NFC-e incorretos | `dfe.lib.acbr.config.pas` | Modelo lido do XML; CSC/IdCSC na empresa; QR Code gerado |
| 14 | **Tabela SVC errada**: GO nas duas listas (caía em SVC-AN), DF em nenhuma | `checarContigenciaManual` | `ContingenciaSvc` corrigida. Também preenche `dhCont`/`xJust` e recalcula a chave, porque o `tpEmis` faz parte dela |
| 15 | **Erros com HTTP 201** e JSON montado por concatenação, sem escape (aspas na mensagem da SEFAZ quebravam o JSON) | `dfe.httpserver.base.pas` (`setResponse`) | Mesmo corpo `{"codretorno":10,"msg":...}` serializado corretamente, com HTTP 400/500 |
| 16 | **DELETE de empresa devolvia texto puro**; o front esperava JSON e mostrava erro | `nfe.controller.empresa.pas` | `{"codretorno":200,"msg":...}` |
| 17 | **Vazamentos**: destructors sem `override` (o `TACBrNFe` nunca era liberado), objetos criados e sobrescritos, `getInfo` sem free | `services/*`, `dao/*`, `controller/*` | Gerenciado pelo GC e pelo DI |
| 18 | **Uma conexão Mongo por DAO**, sem pool (`SetPoolDb` vazio) | `dao/dfe.dao.base.pas` | `MongoClient` singleton com pool |
| 19 | **PDFs acumulados em `reports\`** sem limpeza | `gerarDanfeBase64` | PDF gerado em memória |
| 20 | **CORS refletia qualquer origem**, sem autenticação | `dfe.httpserver.base.pas` | CORS por configuração; API key opcional |
| 21 | **`nfe_app.js` reescrito em runtime** com o IP local (falha com várias interfaces de rede) | `setUpwebTemplate` | `_HOST = window.location.origin` |
| 22 | **Dashboard agrupava pela data/hora exata** (um ponto por nota) e contava erros numa coleção nunca populada | `dao/dfe.dao.infoNfe.pas` | Agrupa por dia (últimos 365 dias); erros = notas sem protocolo |
| 23 | **Log de erros lia a coleção de notas** | `dao/dfe.dao.log.pas` | Removido (logs agora em arquivo, via Serilog) |
| 24 | Servir arquivo estático montando o caminho com a URI (risco de path traversal) | `processcommand` | `UseStaticFiles` |
| 25 | Validação de empresa aceitava qualquer PFX/senha | `nfe.controller.empresa.pas` | PFX aberto com a senha na gravação; validade extraída do certificado; CNPJ validado pelo DV (inclusive alfanumérico) |

## 5. Contrato da API legada (`/dfeapi`)

Mantido sem mudanças para os clientes atuais:

- Rotas e verbos: `GET|POST|PUT /dfeapi/nfe` (despacho por `operacao`), `GET /dfeapi/nfe/info`,
  `GET|POST|PUT|DELETE /dfeapi/nfe/empresa`, `GET /dfeapi/cancelamentos`, `GET /dfeapi/inutilizacoes`, `GET /dfeapi/cartaCorrecao`
- Filtro como JSON cru na query string (`/dfeapi/nfe?{"chave":"..."}`) ou no corpo
- Nomes de campo idênticos aos do Delphi, inclusive com os erros de grafia (`xmlProcesado`, `dataProcesamemento`, `contigencia`, `protocoloCCe`)
- Listas no formato `{"ownsObjects":true,"listHelper":[...]}`
- Datas `yyyy-MM-ddTHH:mm:ss.fffZ` com a hora **local** (o "Z" é herança do `joDateIsUTC` do Delphi); data vazia = `1899-12-30T00:00:00.000Z`
- XMLs em base64 nas respostas de validação e eventos; cStat 5001 para erro local

Mudanças intencionais, que precisam de aviso aos clientes:

| Mudança | Impacto |
|---|---|
| Erros com HTTP 400/500 (antes 201) | Quem tratava 201 como "erro" deve olhar `codretorno` ou o status 4xx/5xx |
| **Campo `txt` (INI do ACBr) não é mais aceito** | Retorna cStat 5001 com mensagem explícita. Os clientes precisam enviar `xml`. Se algum PDV depender do INI, é preciso escrever um conversor INI→XML (fora do escopo atual) |
| `xmlRetorno` do cancelamento passa a ser o `procEventoNFe` (antes: `<nfeCanc>` + envio + retorno) | Quem fazia parse do wrapper `<nfeCanc>` precisa ajustar |
| Empresa não devolve mais `certificadoPfx`/`senhaPfx` (vêm vazios) e ganhou `possuiCertificado`, `csc` e `idCsc` | O front continua funcionando: gravar com o PFX vazio mantém o atual |
| `operacao: "imprimir"` agora funciona: `{"codretorno":1,"arquivo":"<pdf base64>"}` a partir de `chave` | Antes era um TODO |
| `DELETE /dfeapi/nfe` responde 405 | Antes não respondia nada |
| Acentos: o XML não tem mais os acentos removidos (`RemoverAcentos = false`) | Removê-los depois da assinatura invalidaria o digest; o XML vai como o cliente gerou |
| Charset da resposta: UTF-8 (o Indy usava iso-8859-1) | Se algum PDV mostrar acentos quebrados, configure `ApiLegada:Charset = "iso-8859-1"` |

## 6. Riscos e limitações conhecidos

- **Reserialização do XML pelo Zeus**: o XML do cliente é desserializado no modelo do Zeus e
  serializado de novo antes de assinar (o ACBr fazia o mesmo). Um campo que o Zeus não modele é
  descartado sem aviso. Conferir com XMLs reais da reforma tributária (IBS/CBS) na Fase 1.
- **DANFE de cancelamento e de inutilização**: o Zeus não tem esses relatórios. O cancelamento tenta o
  `EventoNfeDocument` (feito para CC-e) e devolve `danfe` vazio se falhar; a inutilização não gera PDF.
- **PDFClown só publica build .NET Framework** (aviso NU1701 suprimido). O teste de DANFE A4 passa
  no .NET 8 no Windows; validar no Linux antes de containerizar.
- **QuestPDF Community** é gratuita só para empresas com receita anual abaixo de US$ 1 milhão. Acima
  disso, comprar licença e configurar `Danfe:LicencaQuestPdf`.
- **Chave com CNPJ alfanumérico**: o cálculo do DV usa (ASCII − 48) por caractere, igual ao CNPJ.
  Validar contra a NT da chave de acesso quando houver emissor com CNPJ alfanumérico.
- **Contingência offline da NFC-e (tpEmis 9)** não foi portada (o Delphi também não tinha).
- **Envio assíncrono**: se o lote continuar em 105 depois de 5 consultas, a nota é gravada com 105 e o
  cliente precisa reenviar. O reenvio cai em duplicidade e recupera o protocolo.

## 7. Configuração (`src/NfeServer.Api/appsettings.json`)

| Chave | Padrão | Observação |
|---|---|---|
| `Urls` | `http://0.0.0.0:4475` | Mesma porta do Delphi |
| `Mongo:ConnectionString` / `Database` | `mongodb://localhost:27017/?serverSelectionTimeoutMS=5000` / `nfeDb` | Mesmo banco do Delphi |
| `Emissao:UfsEnvioAssincrono` | `["SP","BA"]` | Era fixo no código |
| `Sefaz:TimeoutMs` | `30000` | |
| `Sefaz:DiretorioSchemas` | vazio | Vazio = sem validação local de XSD |
| `Sefaz:VersaoQrCodeNfce` | `2` | Confirmar com a NT vigente |
| `Sefaz:TentativasConsultaRecibo` | `5` | |
| `Danfe:CaminhoLogo` | `logo/logo.bmp` | |
| `Seguranca:ApiKeys` | `[]` | Vazio = sem autenticação (aviso no log) |
| `Seguranca:ProtegerSegredosNoBanco` | `false` | Ligar só depois de desligar o Delphi |
| `Seguranca:DiretorioChaves` | `%ProgramData%\NfeServer\chaves` | Chaves do Data Protection; **fazer backup** |
| `ApiLegada:Charset` | `utf-8` | |
| `Cors:Origens` | `[]` | O front é servido pela mesma origem |

## 8. Como rodar

```powershell
dotnet test                                   # 46 testes
dotnet run --project src/NfeServer.Api        # http://localhost:4475 (Swagger em /swagger)

# Publicação como serviço Windows
dotnet publish src/NfeServer.Api -c Release -o C:\NfeServer
sc.exe create NfeServer binPath= "C:\NfeServer\NfeServer.Api.exe" start= auto
sc.exe start NfeServer
```

Requisitos: SDK .NET 8, MongoDB acessível e certificado A1 (PFX) cadastrado pela tela de empresa ou por `PUT /api/v2/empresas/{cnpj}`.

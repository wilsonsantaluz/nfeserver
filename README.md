# NfeServer

Servidor HTTP de emissão de **NF-e (modelo 55)** e **NFC-e (modelo 65)** em .NET 8, sobre a biblioteca
[Zeus DFe.NET](https://github.com/ZeusAutomacao/DFe.NET) e MongoDB. Substitui o antigo servidor
Delphi/ACBr mantendo o mesmo contrato HTTP (`/dfeapi/*`), o mesmo banco (`nfeDb`) e o mesmo painel web.

| Documento | Conteúdo |
|---|---|
| Este README | Como o sistema funciona, como rodar, configurar, chamar a API e resolver problemas |
| [PLANO_MIGRACAO_DOTNET.md](PLANO_MIGRACAO_DOTNET.md) | Decisões da migração, bugs do Delphi corrigidos, mudanças de contrato, pendências por fase |
| [docs/ROADMAP_IA.md](docs/ROADMAP_IA.md) | Planos futuros: resiliência inteligente, diagnóstico de rejeições e validação com IA |

---

## Sumário

1. [O que o servidor faz](#1-o-que-o-servidor-faz)
2. [Início rápido](#2-início-rápido)
3. [Arquitetura](#3-arquitetura)
4. [Fluxos fiscais](#4-fluxos-fiscais)
5. [API legada `/dfeapi`](#5-api-legada-dfeapi)
6. [API REST v2 `/api/v2`](#6-api-rest-v2-apiv2)
7. [Banco de dados](#7-banco-de-dados)
8. [Configuração](#8-configuração)
9. [Segurança](#9-segurança)
10. [Logs, health check e diagnóstico](#10-logs-health-check-e-diagnóstico)
11. [Testes](#11-testes)
12. [Publicação e instalação](#12-publicação-e-instalação)
13. [Problemas comuns](#13-problemas-comuns)
14. [Como estender](#14-como-estender)

---

## 1. O que o servidor faz

O cliente (PDV, ERP ou o painel web) envia o **XML da nota já montado** em base64. O servidor:

1. identifica a empresa emissora pelo CNPJ e carrega o certificado A1 dela;
2. aplica a contingência SVC, se estiver ativada para a empresa;
3. assina o XML e gera o QR Code (NFC-e);
4. envia à SEFAZ da UF (síncrono ou assíncrono, conforme a UF);
5. trata a duplicidade (204/539) consultando o protocolo;
6. monta o `nfeProc` (XML autorizado), gera o DANFE em PDF e grava tudo no MongoDB;
7. devolve status, protocolo, XML autorizado e DANFE.

Também faz **cancelamento**, **carta de correção (CC-e)**, **inutilização de numeração**,
listagens, dashboard e o cadastro de empresas e certificados.

O servidor **não monta a nota a partir de dados de venda**. O cliente gera o XML; o servidor
cuida da comunicação fiscal. O formato TXT/INI do ACBr não é aceito.

## 2. Início rápido

### Pré-requisitos

- [SDK .NET 8](https://dotnet.microsoft.com/download/dotnet/8.0)
- MongoDB 5+ (local ou remoto)
- Para emitir: certificado A1 (`.pfx`) válido, do CNPJ emitente

### MongoDB local com Docker (opcional)

```powershell
docker run -d --name nfe-mongo -p 27017:27017 -v nfe-mongo:/data/db mongo:7
```

### Rodar

```powershell
dotnet test                                # 46 testes, não precisam de banco nem de internet
dotnet run --project src/NfeServer.Api     # sobe em http://localhost:4475
```

| URL | O que é |
|---|---|
| `http://localhost:4475/` | Painel web (dashboard, notas, cancelamentos, empresas) |
| `http://localhost:4475/swagger` | Swagger das APIs v2 e legada (só em Development) |
| `http://localhost:4475/health` | Health check (200 = MongoDB respondendo) |

### Primeira emissão em homologação

1. No painel, abra **Empresa** e cadastre CNPJ, razão social, UF, ambiente **Homologação**, o `.pfx` e a senha.
   Para NFC-e, informe também o CSC e o IdCSC (pela API v2; veja a seção 6).
2. Envie o XML (com `tpAmb=2`) pela API:

```powershell
$xml = [Convert]::ToBase64String([IO.File]::ReadAllBytes("nota.xml"))
$corpo = @{ operacao = "validacao"; cnpj = "11222333000181"; xml = $xml } | ConvertTo-Json
Invoke-RestMethod -Method Put -Uri http://localhost:4475/dfeapi/nfe -ContentType "application/json" -Body $corpo
```

## 3. Arquitetura

Clean Architecture em quatro projetos. As dependências apontam só para dentro:

```
              ┌──────────────────────────────────────────────┐
              │ NfeServer.Api (ASP.NET Core)                 │
              │  Legado/  /dfeapi/*  contrato do Delphi      │
              │  V2/      /api/v2/*  REST novo               │
              │  wwwroot/ painel web                         │
              └───────────────┬──────────────────────────────┘
                              │
              ┌───────────────▼──────────────────────────────┐
              │ NfeServer.Infrastructure                     │
              │  Fiscal/  ZeusSefazNFeGateway (Zeus DFe.NET) │
              │  Pdf/     DanfeService (PdfClown, QuestPDF)  │
              │  Persistencia/Mongo/ repositórios            │
              │  Certificados/, Seguranca/                   │
              └───────────────┬──────────────────────────────┘
                              │ implementa as portas
              ┌───────────────▼──────────────────────────────┐
              │ NfeServer.Application                        │
              │  CasosDeUso/  Autorizar, Cancelar, CC-e,     │
              │               Inutilizar, Empresas, Consultas│
              │  Abstracoes/  ISefazNFeGateway, IDanfeService│
              │               repositórios (portas)          │
              └───────────────┬──────────────────────────────┘
                              │
              ┌───────────────▼──────────────────────────────┐
              │ NfeServer.Domain (sem dependências)          │
              │  ChaveAcesso, Cnpj, Uf, ContingenciaSvc,     │
              │  CodigosRetorno, Justificativa, entidades    │
              └──────────────────────────────────────────────┘
```

**Por que assim:** as regras fiscais (casos de uso) não conhecem Zeus, MongoDB nem HTTP. A porta
[`ISefazNFeGateway`](src/NfeServer.Application/Abstracoes/ISefazNFeGateway.cs) trafega só XML em
string, então dá para trocar o Zeus por outra biblioteca reescrevendo um único adaptador.

### Mapa de pastas

| Caminho | Responsabilidade |
|---|---|
| [src/NfeServer.Domain/Fiscal/ChaveAcesso.cs](src/NfeServer.Domain/Fiscal/ChaveAcesso.cs) | Composição, validação (DV módulo 11) e extração da chave de 44 posições |
| [src/NfeServer.Domain/Fiscal/Cnpj.cs](src/NfeServer.Domain/Fiscal/Cnpj.cs) | CNPJ numérico e alfanumérico |
| [src/NfeServer.Domain/Fiscal/ContingenciaSvc.cs](src/NfeServer.Domain/Fiscal/ContingenciaSvc.cs) | UF → SVC-AN ou SVC-RS |
| [src/NfeServer.Domain/Comum/CodigosRetorno.cs](src/NfeServer.Domain/Comum/CodigosRetorno.cs) | cStat usados nas regras (100, 204, 135, 577...) e o 5001 interno |
| [src/NfeServer.Application/CasosDeUso/](src/NfeServer.Application/CasosDeUso/) | Um arquivo por caso de uso |
| [src/NfeServer.Application/Consultas/FiltroConsulta.cs](src/NfeServer.Application/Consultas/FiltroConsulta.cs) | Filtros de listagem com lista branca de campos |
| [src/NfeServer.Infrastructure/Fiscal/ZeusSefazNFeGateway.cs](src/NfeServer.Infrastructure/Fiscal/ZeusSefazNFeGateway.cs) | Toda a comunicação com a SEFAZ |
| [src/NfeServer.Infrastructure/Fiscal/ConfiguracaoZeus.cs](src/NfeServer.Infrastructure/Fiscal/ConfiguracaoZeus.cs) | `ConfiguracaoServico` do Zeus por chamada |
| [src/NfeServer.Infrastructure/Certificados/ProvedorCertificados.cs](src/NfeServer.Infrastructure/Certificados/ProvedorCertificados.cs) | Carga e cache do A1 em memória |
| [src/NfeServer.Infrastructure/Pdf/DanfeService.cs](src/NfeServer.Infrastructure/Pdf/DanfeService.cs) | DANFE NF-e (A4), NFC-e (80 mm) e CC-e |
| [src/NfeServer.Infrastructure/Persistencia/Mongo/](src/NfeServer.Infrastructure/Persistencia/Mongo/) | Mapeamento compatível com o Delphi e repositórios |
| [src/NfeServer.Api/Legado/](src/NfeServer.Api/Legado/) | Endpoints `/dfeapi`, DTOs e JSON no formato do Delphi |
| [src/NfeServer.Api/V2/](src/NfeServer.Api/V2/) | Endpoints `/api/v2` |
| [src/NfeServer.Api/Program.cs](src/NfeServer.Api/Program.cs) | Composição: DI, Serilog, serviço Windows, middlewares |
| [tests/NfeServer.UnitTests/](tests/NfeServer.UnitTests/) | Testes de domínio, contrato, casos de uso e Zeus offline |

### Concorrência

Cada requisição tem seus próprios controller, caso de uso e `ConfiguracaoServico` do Zeus. O singleton
`ConfiguracaoServico.Instancia` do Zeus **nunca** é usado, de modo que empresas diferentes podem emitir em
paralelo. O certificado fica em cache por CNPJ + hash do PFX: trocar o PFX invalida o cache sozinho.

## 4. Fluxos fiscais

### 4.1 Autorização ([AutorizarNotaFiscal.cs](src/NfeServer.Application/CasosDeUso/AutorizarNotaFiscal.cs))

```
cliente ──XML base64──► AutorizarNotaFiscal
   1. carrega a empresa pelo CNPJ (erro 5001 se não existir ou estiver sem certificado)
   2. Preparar: lê o XML (aceita <NFe> ou <nfeProc>), confere tpAmb com o ambiente da empresa,
      aplica a contingência SVC se ativa, assina e gera o QR Code (NFC-e)
   3. já existe nota com essa chave E com protocolo?  ──sim──► devolve a gravada (não reenvia)
   4. envia à SEFAZ
        - UF em Emissao:UfsEnvioAssincrono (SP, BA) → assíncrono + consulta ao recibo
        - demais → síncrono (se a SEFAZ responder 103, consulta o recibo mesmo assim)
   5. cStat 204/539 (duplicidade) sem protocolo → consulta o protocolo pela chave do xMotivo
        - mesma chave: recupera o protocolo e segue como autorizada
        - chave diferente (cNF divergente): mantém a rejeição e informa a chave autorizada
   6. com protocolo: monta o nfeProc sem reserializar o XML assinado; se cStat 100/150, gera o DANFE
   7. grava (upsert pela chave) sempre que houve envio à SEFAZ
```

Erros locais (empresa inexistente, XML inválido, certificado vencido) voltam com **cStat 5001** e a
mensagem em `xmotivo`. Rejeições da SEFAZ voltam com o cStat da SEFAZ. Nos dois casos, HTTP 200 na API legada.

### 4.2 Contingência SVC

Liga com `contigencia = 1` na empresa (manual, como no Delphi). Só vale para **NF-e**; NFC-e não usa SVC.

- AM, BA, CE, GO, MA, MS, MT, PA, PE, PI, PR → **SVC-RS** (`tpEmis = 7`)
- demais UFs → **SVC-AN** (`tpEmis = 6`)

Como o `tpEmis` faz parte da chave de acesso, o servidor **recalcula a chave e o DV** e preenche
`dhCont` e `xJust`. Se o cliente já mandou o XML em contingência (`tpEmis ≠ 1`), ele é respeitado.

### 4.3 Cancelamento ([CancelarNotaFiscal.cs](src/NfeServer.Application/CasosDeUso/CancelarNotaFiscal.cs))

- Justificativa de 15 a 255 caracteres.
- Se o protocolo de autorização não vier no pedido, é buscado na nota gravada.
- `dhEvento`: a data/hora do pedido, se tiver hora e não estiver no futuro; senão, agora.
- Rejeição **577** (data/hora do evento) → reenvia uma vez com a hora atual.
- Aceito (135, 136, 155) → marca a nota como cancelada e devolve o `procEventoNFe`.
- **573** (evento duplicado) não é gravado.

### 4.4 Carta de correção

Só NF-e (modelo 55). Texto de 15 a 1000 caracteres, sequência de 1 a 20. Gera o PDF da CC-e se a
nota estiver na base.

### 4.5 Inutilização

Modelo 55 ou 65, faixa válida, justificativa de 15 a 255 caracteres. O ano vai com 2 dígitos. Homologada
(102) devolve o `procInutNFe`; **563** (duplicada) não é gravada.

### 4.6 Códigos de retorno que o servidor trata

| cStat | Significado | O que o servidor faz |
|---|---|---|
| 100 / 150 | Autorizada (150 = fora do prazo) | Monta o nfeProc, gera o DANFE, grava |
| 110, 301-303 | Denegada | Grava com protocolo, sem DANFE |
| 103 / 105 | Lote recebido / em processamento | Consulta o recibo até 5 vezes |
| 204 / 539 | Duplicidade | Consulta o protocolo (seção 4.1) |
| 135 / 136 / 155 | Evento registrado | Cancelamento/CC-e aceitos |
| 573 | Evento duplicado | Não grava |
| 577 | Data do evento rejeitada | Reenvia o cancelamento com a hora atual |
| 102 / 563 | Inutilização homologada / duplicada | 563 não grava |
| **5001** | **Erro local do servidor** | Mensagem em `xmotivo`/`msg` |

## 5. API legada `/dfeapi`

Mantém o contrato do servidor Delphi. Particularidades:

- POST/PUT recebem JSON no corpo; GET/DELETE aceitam o filtro **cru na query string**:
  `GET /dfeapi/nfe?{"chave":"3526..."}`.
- Listas vêm como `{"ownsObjects":true,"listHelper":[...]}` (formato do `TObjectList` do Delphi).
- Datas: `"2026-10-01T14:05:09.120Z"`. O "Z" é herança do Delphi: **a hora é local**, não UTC.
  Data vazia = `"1899-12-30T00:00:00.000Z"`.
- Nomes de campo com a grafia original: `xmlProcesado`, `dataProcesamemento`, `contigencia`, `protocoloCCe`.
- Erros: `{"codretorno":10,"msg":"..."}` com HTTP 400 (regra de negócio) ou 500 (erro interno).

### Rotas

| Método e rota | Ação |
|---|---|
| `POST`/`PUT /dfeapi/nfe` com `operacao` | `validacao`, `cancelamento`, `inutilizacao`, `cartacorrecao`, `imprimir` |
| `GET /dfeapi/nfe?{filtro}` | Lista notas (filtros: cnpj, numero, serie, modelo, chave, status, protocolo, cancelada) |
| `GET /dfeapi/nfe/info` | Dashboard |
| `GET /dfeapi/nfe/empresa?{filtro}` | Lista empresas (sem PFX, senha e CSC) |
| `POST`/`PUT /dfeapi/nfe/empresa` | Grava empresa |
| `DELETE /dfeapi/nfe/empresa?{"cnpj":"..."}` | Exclui empresa |
| `GET /dfeapi/cancelamentos?{filtro}` | Lista cancelamentos |
| `GET /dfeapi/inutilizacoes?{filtro}` | Lista inutilizações |
| `GET /dfeapi/cartaCorrecao?{filtro}` | Lista cartas de correção |

### Exemplos de corpo

```jsonc
// validacao → resposta: cnpj, numero, serie, modelo, chave, cstat, xmotivo, protocolo, digito,
//             xmlProcesado (base64), xmlRetorno (base64), danfeBase64, dataProcesamemento, dataValidacao
{ "operacao": "validacao", "cnpj": "11222333000181", "numero": 123, "serie": 1, "modelo": 55, "xml": "<base64 do XML>" }

// cancelamento → resposta: ... protocoloCancelamento, cstat, xmotivo, xmlRetorno (base64 do procEventoNFe), danfe
{ "operacao": "cancelamento", "cnpj": "11222333000181", "chave": "3526...", "protocolo": "135260000000001",
  "justificativa": "Cancelamento por erro de digitacao", "data": "2026-10-01T15:30:00" }

// cartacorrecao
{ "operacao": "cartacorrecao", "cnpj": "11222333000181", "chave": "3526...", "sequencia": 1,
  "xcorrecao": "Corrigir o endereco do destinatario para Rua B, 200" }

// inutilizacao
{ "operacao": "inutilizacao", "cnpj": "11222333000181", "modelo": 55, "serie": 1, "ano": 2026,
  "numeroInicial": 10, "numeroFinal": 12, "justificativa": "Falha no sistema de numeracao" }

// imprimir → { "codretorno": 1, "msg": "DANFE gerado", "arquivo": "<pdf base64>" }
{ "operacao": "imprimir", "chave": "3526..." }
```

## 6. API REST v2 `/api/v2`

Contrato novo, JSON em camelCase e datas ISO. Rejeições da SEFAZ voltam **200** com o cStat no corpo
(o documento foi processado). Erros locais (cStat 5001) voltam **422** com `ProblemDetails`.

| Método e rota | Corpo / parâmetros | Resposta |
|---|---|---|
| `POST /api/v2/notas` | `{ "cnpj", "xml" }` (XML em texto, sem base64) | `NotaResponse` |
| `GET /api/v2/notas?cnpj=&serie=&status=` | filtros por igualdade | lista resumida (sem XML) |
| `GET /api/v2/notas/{chave}` | | nota com XML e retorno |
| `GET /api/v2/notas/{chave}/danfe` | | `application/pdf` |
| `POST /api/v2/notas/{chave}/cancelamento` | `{ "cnpj", "justificativa", "protocolo"? }` | `EventoResponse` |
| `POST /api/v2/notas/{chave}/cartas-correcao` | `{ "cnpj", "correcao", "sequencia" }` | `EventoResponse` |
| `POST /api/v2/inutilizacoes` | `{ "cnpj", "modelo", "ano", "serie", "numeroInicial", "numeroFinal", "justificativa" }` | `InutilizacaoResponse` |
| `GET /api/v2/inutilizacoes` | filtros | lista |
| `GET /api/v2/empresas` · `GET /api/v2/empresas/{cnpj}` | | sem segredos; com `possuiCertificado`, `possuiCsc` |
| `PUT /api/v2/empresas/{cnpj}` | `EmpresaRequest` (inclui `certificadoPfxBase64`, `senhaPfx`, `csc`, `idCsc`) | `{ "mensagem" }` |
| `DELETE /api/v2/empresas/{cnpj}` | | 204 |
| `GET /api/v2/dashboard` | | resumo |

Campos de certificado, senha e CSC **vazios numa atualização mantêm os valores já gravados**. A validade
do certificado é lida do próprio PFX: um PFX com a senha errada é recusado na hora de gravar.

## 7. Banco de dados

Banco `nfeDb`, as mesmas coleções e campos do servidor Delphi (os dois podem ler o mesmo banco durante a transição).

| Coleção | Conteúdo | Chave lógica |
|---|---|---|
| `empresas` | Cadastro, certificado (base64), senha, ambiente, contingência, CSC | `cnpj` (upsert) |
| `notas` | XML (nfeProc quando autorizada), retorno, status, protocolo, DANFE base64 | `chave` (upsert) |
| `cancelamentos` | Pedido e resultado do cancelamento | um documento por tentativa |
| `inutilizacoes` | Faixa, protocolo, procInutNFe | um documento por tentativa |
| `cartacorrecao` | Sequência, texto, procEventoNFe | um documento por tentativa |

Compatibilidade com o Delphi ([MapeamentoMongo.cs](src/NfeServer.Infrastructure/Persistencia/Mongo/MapeamentoMongo.cs)):

- datas gravadas como **string** no formato do Delphi; a leitura aceita string, BSON date e TDateTime numérico;
- `numero` gravado como Int32;
- campos novos (`modelo`, `ambiente` em notas; `csc`, `idCsc` em empresas) são ignorados pelo Delphi.

Índices recomendados (não são criados automaticamente):

```javascript
use nfeDb
db.notas.createIndex({ chave: 1 })
db.notas.createIndex({ cnpj: 1, serie: 1, numero: 1 })
db.empresas.createIndex({ cnpj: 1 }, { unique: true })
db.cancelamentos.createIndex({ chave: 1 })
```

## 8. Configuração

Arquivo [src/NfeServer.Api/appsettings.json](src/NfeServer.Api/appsettings.json). Qualquer chave pode ser
sobrescrita por variável de ambiente com `__` (ex.: `Mongo__ConnectionString`).

| Chave | Padrão | Descrição |
|---|---|---|
| `Urls` | `http://0.0.0.0:4475` | Endereço e porta (a mesma do Delphi) |
| `Mongo:ConnectionString` | `mongodb://localhost:27017/?serverSelectionTimeoutMS=5000` | |
| `Mongo:Database` | `nfeDb` | |
| `Emissao:UfsEnvioAssincrono` | `["SP","BA"]` | UFs com envio em lote assíncrono |
| `Sefaz:TimeoutMs` | `30000` | Timeout de cada chamada à SEFAZ |
| `Sefaz:DiretorioSchemas` | vazio | Pasta dos XSD do PL vigente; vazio = sem validação local |
| `Sefaz:ValidarCertificadoServidor` | `false` | Validar a cadeia TLS da SEFAZ (ICP-Brasil) |
| `Sefaz:TentativasConsultaRecibo` | `5` | Consultas enquanto o lote está em 105 |
| `Sefaz:VersaoQrCodeNfce` | `2` | Versão do QR Code da NFC-e (confirmar na NT da UF) |
| `Danfe:CaminhoLogo` | `logo/logo.bmp` | Relativo à pasta do executável |
| `Danfe:LicencaQuestPdf` | `Community` | Licença do QuestPDF (veja a seção 9) |
| `Seguranca:ApiKeys` | `[]` | Chaves aceitas em `X-Api-Key`; vazio = sem autenticação |
| `Seguranca:ProtegerSegredosNoBanco` | `false` | Criptografar senha do PFX e CSC no banco |
| `Seguranca:DiretorioChaves` | `%ProgramData%\NfeServer\chaves` | Anel de chaves do Data Protection |
| `ApiLegada:Charset` | `utf-8` | Use `iso-8859-1` se algum PDV antigo exibir acentos quebrados |
| `Cors:Origens` | `[]` | Origens liberadas (o painel é servido pela mesma origem) |
| `Serilog` | console + `logs/nfeserver-AAAAMMDD.log` | Retenção de 60 dias |

## 9. Segurança

- **API key:** configure `Seguranca:ApiKeys` e mande `X-Api-Key: <chave>` em `/dfeapi` e `/api`.
  Sem chaves, a API fica aberta como era no Delphi, e o log avisa isso ao subir.
- **Segredos no banco:** com `ProtegerSegredosNoBanco = true`, a senha do PFX e o CSC são gravados com o
  prefixo `dp1:`, criptografados pelo Data Protection (chaves protegidas por DPAPI da máquina). Ligue só
  depois de desligar o Delphi, que lê texto puro. **Faça backup de `DiretorioChaves`**: sem ele, os segredos
  não podem ser lidos.
- **Listagens** nunca devolvem PFX, senha nem CSC.
- **Filtros** só aceitam campos de uma lista branca e valores escalares; operadores do Mongo (`$ne`, `$where`) são recusados.
- **Certificados** nunca vão para disco nem para o git (`*.pfx` está no `.gitignore`).
- **Licenças de terceiros:** Zeus e PDFClown são LGPL. O QuestPDF Community é gratuito só para receita
  anual abaixo de US$ 1 milhão.

## 10. Logs, health check e diagnóstico

- Log em `logs/nfeserver-AAAAMMDD.log` (ao lado do executável quando roda como serviço). Cada envio à
  SEFAZ registra chave, cStat e xMotivo; duplicidades, contingência e falhas de gravação têm nível Warning/Critical.
- `GET /health` → 200 `Healthy` ou 503 `Unhealthy` (MongoDB fora).
- O XML de retorno de cada operação fica gravado no documento (`xmlRetorno`/`xmlEvento`), o que ajuda a
  investigar rejeições.
- **Falha ao gravar depois de falar com a SEFAZ** gera log `Critical` e o cliente recebe o resultado do
  mesmo jeito. Um reenvio da nota cai em duplicidade e se recupera pela consulta de protocolo.

## 11. Testes

```powershell
dotnet test
```

| Arquivo | Cobre |
|---|---|
| [Dominio/DominioTests.cs](tests/NfeServer.UnitTests/Dominio/DominioTests.cs) | Chave de acesso, CNPJ (inclusive alfanumérico), SVC, justificativa |
| [Legado/ContratoLegadoTests.cs](tests/NfeServer.UnitTests/Legado/ContratoLegadoTests.cs) | JSON no formato do Delphi, datas, filtros e injeção |
| [CasosDeUso/CasosDeUsoTests.cs](tests/NfeServer.UnitTests/CasosDeUso/CasosDeUsoTests.cs) | Autorização, duplicidade 204/539, cancelamento 577/573, inutilização (com fakes) |
| [Infraestrutura/ZeusGatewayTests.cs](tests/NfeServer.UnitTests/Infraestrutura/ZeusGatewayTests.cs) | Zeus de verdade, offline: assinatura válida no nfeProc, contingência, DANFE A4 |

Os testes do Zeus usam um certificado autoassinado gerado na hora; não precisam de PFX real nem de internet.
**Ainda não há testes contra MongoDB real nem contra a SEFAZ de homologação** (veja a Fase 1 do plano).

## 12. Publicação e instalação

```powershell
dotnet publish src/NfeServer.Api -c Release -o C:\NfeServer

# serviço Windows (prompt como administrador)
sc.exe create NfeServer binPath= "C:\NfeServer\NfeServer.Api.exe" start= auto
sc.exe failure NfeServer reset= 86400 actions= restart/5000/restart/5000/restart/30000
sc.exe start NfeServer
```

- Configure via `C:\NfeServer\appsettings.json` ou variáveis de ambiente do serviço.
- Logo do DANFE: `C:\NfeServer\logo\logo.bmp`.
- O serviço roda como LocalSystem por padrão; ele precisa gravar em `logs\` e em `DiretorioChaves`.
- Atualização: `sc.exe stop NfeServer`, copiar a nova publicação por cima (preservando o `appsettings.json`), `sc.exe start NfeServer`.

## 13. Problemas comuns

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| `5001 Nenhuma empresa cadastrada...` | CNPJ do pedido não está em `empresas` | Cadastrar a empresa; conferir o CNPJ sem máscara |
| `5001 O ambiente do XML (tpAmb=2) difere...` | XML em homologação e empresa em produção, ou o contrário | Ajustar o `tpAmb` do XML ou o ambiente da empresa |
| `5001 O certificado está vencido...` | A1 expirado | Gravar o novo PFX na empresa |
| `5001 ... senha incorreta ou arquivo inválido` | Senha errada ou PFX corrompido | Reenviar o PFX/senha |
| `5001 CSC e IdCSC não configurados...` | NFC-e sem CSC | Cadastrar o CSC pela API v2 |
| `5001 Envio em TXT/INI...` | Cliente enviando o formato do ACBr | Enviar o XML em `xml` |
| `5001 A timeout occurred after 5000ms selecting a server` | MongoDB fora do ar | Subir o MongoDB / conferir a connection string |
| cStat 105 "Lote em processamento" | SEFAZ lenta no assíncrono | Reenviar a nota mais tarde (vai cair em 204 e recuperar) |
| cStat 204 com motivo "NF-e já autorizada com a chave..." | Mesmo número já autorizado com outro cNF | A nota autorizada é a da chave informada; não emitir de novo |
| cStat 225 / 215 (falha de schema) | XML fora do leiaute | Conferir com o XSD; ativar `Sefaz:DiretorioSchemas` para ver o erro antes do envio |
| cStat 108 / 109 (serviço paralisado) | SEFAZ fora | Ativar a contingência SVC na empresa (NF-e) |
| Acentos quebrados no PDV | Cliente lê a resposta como Latin-1 | `ApiLegada:Charset = "iso-8859-1"` |
| `/health` 503 | MongoDB inacessível | Ver log e conexão |

## 14. Como estender

- **Trocar a biblioteca fiscal:** implementar `ISefazNFeGateway` (e `IDanfeService`, se for o caso) em
  `Infrastructure` e trocar o registro em [DependencyInjection.cs](src/NfeServer.Infrastructure/DependencyInjection.cs).
  Os casos de uso e os testes de caso de uso não mudam.
- **Nova operação fiscal** (ex.: manifestação do destinatário): método novo na porta → implementação no
  gateway Zeus → caso de uso em `Application/CasosDeUso` → endpoint v2 → testes com o `FakeSefaz`.
- **Novo campo filtrável:** incluir o nome em `CamposFiltro` ([FiltroConsulta.cs](src/NfeServer.Application/Consultas/FiltroConsulta.cs)).
- **Migrar para .NET 10:** trocar `net8.0` por `net10.0` nos `.csproj` e os pacotes `8.x` por `10.x`.
  O suporte do .NET 8 termina em 10/11/2026.
- **IA, resiliência e contingência automática:** [docs/ROADMAP_IA.md](docs/ROADMAP_IA.md).

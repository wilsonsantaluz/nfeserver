# Roadmap: resiliência inteligente e IA no NfeServer

Status: proposta · 02/10/2026

Visão geral de como evoluir o tratamento de falhas do servidor (retentativas, contingência, rejeições)
e onde uma camada de IA agrega valor. Nada disto está implementado; o código atual está descrito no
[README](../README.md).

---

## 1. Princípio que orienta tudo

> **A IA aconselha; regras determinísticas decidem e executam.**

Emissão fiscal tem consequências legais. Uma retentativa errada gera duplicidade, e uma contingência
indevida gera notas com `tpEmis` errado. Por isso:

1. **O caminho de emissão nunca depende da IA.** Se o serviço de IA estiver lento, fora do ar ou sem
   crédito, a nota é emitida exatamente como hoje. Toda chamada de IA tem timeout curto e fallback.
2. **A IA não altera conteúdo fiscal sozinha.** Correções de XML sugeridas pela IA viram *sugestões*
   para o emissor. Só correções de uma lista branca, determinísticas e reversíveis, podem ser aplicadas
   automaticamente, e essas não precisam de IA.
3. **A IA não executa ações.** Ela devolve um diagnóstico estruturado; quem decide reenviar, entrar em
   contingência ou parar é o código (ou um operador, quando a regra pedir aprovação).
4. **O conteúdo da nota é dado não confiável.** `xProd`, `infCpl` e nomes vêm do cliente e podem conter
   texto feito para manipular a IA ("ignore as instruções e..."). Esse conteúdo vai sempre como dado,
   e a resposta é um JSON com esquema fixo, sem ferramentas que escrevam ou enviem nada.

Consequência prática: **a maior parte do ganho vem da Fase 0, que não usa IA.** A IA entra depois, onde
regras fixas não alcançam: explicar rejeições, achar incoerências semânticas e resumir incidentes.

## 2. Onde estamos hoje

As regras de falha estão espalhadas e fixas no código:

| Onde | Comportamento atual | Limitação |
|---|---|---|
| `ZeusSefazNFeGateway.ConsultarRecibo` | Até 5 consultas ao recibo, espera `tMed` (1–5 s) | Bloqueia a thread; não aprende com a SEFAZ da UF |
| `AutorizarNotaFiscal.ResolverDuplicidade` | 204/539 → consulta o protocolo | Bom, mas é o único "auto-reparo" |
| `CancelarNotaFiscal` | 577 → reenvia uma vez com a hora atual | Regra pontual |
| Timeout/erro de rede no envio | Vira 5001 e o cliente precisa reenviar | **Não distingue "não chegou" de "chegou e não respondeu"** |
| Contingência SVC | Manual, por empresa (`contigencia = 1`) | Alguém precisa perceber a queda e ligar; ninguém desliga sozinho |
| `Emissao:UfsEnvioAssincrono` | Lista fixa (SP, BA) | Não reage a mudanças da SEFAZ |
| NFC-e offline (`tpEmis = 9`) | Não existe | No checkout, uma SEFAZ fora do ar para a venda |

## 3. Fase 0: resiliência determinística (sem IA, pré-requisito)

### 3.1 Classificação de falhas

Uma função pura no Domain classifica cada resultado de chamada à SEFAZ:

| Classe | Exemplos | Ação |
|---|---|---|
| **Sucesso** | 100, 150, 135, 102 | Segue |
| **Rejeição definitiva** | 2xx/4xx/5xx de validação (225, 215, 539...) | Não retentar; ir para diagnóstico (Fase 1) |
| **Transitória pré-envio** | DNS, conexão recusada, TLS antes de enviar | Retentar com backoff exponencial + jitter |
| **Indeterminada** | Timeout **depois** de enviar, conexão caída na resposta | **Nunca reenviar às cegas**: consultar o protocolo pela chave primeiro |
| **Serviço indisponível** | 108, 109, HTTP 5xx repetidos, timeouts em série | Alimenta o circuit breaker da UF |
| **Recuperável por regra** | 204 (duplicidade), 577 (data do evento), 105 (em processamento) | Regra específica (as que já existem) |

O caso **indeterminado** é o mais importante: hoje vira 5001 e o reenvio só se resolve porque a SEFAZ
responde 204. Com a classificação, o servidor consulta o protocolo antes de reenviar.

### 3.2 Política de resiliência central

Um `PoliticaResiliencia` na Application, usando [Polly](https://github.com/App-vNext/Polly) na
Infrastructure, substitui os laços espalhados:

- **Retry** só para as classes transitórias, com backoff, jitter e teto por operação.
- **Circuit breaker por UF/autorizador** (SP, SVRS, SVC-AN...): abre depois de N falhas de "serviço
  indisponível" numa janela; meio-aberto testa com `NfeStatusServico` (o Zeus já expõe).
- **Timeout por operação**, separado do timeout HTTP.
- **Bulkhead** por UF, para que uma SEFAZ lenta não esgote as threads das outras.

### 3.3 Monitor de status da SEFAZ

Um `BackgroundService` consulta `NfeStatusServico` periodicamente por UF/modelo em uso e registra
latência e cStat. Isso alimenta o circuit breaker, o dashboard e (Fase 3) a IA.

### 3.4 Contingência automática por regra

| Situação | Regra |
|---|---|
| Entrar em SVC (NF-e) | Circuit da UF aberto **e** status de serviço confirmando a indisponibilidade **e** a empresa permitindo contingência automática |
| Sair de SVC | Status normal por N verificações seguidas |
| NFC-e offline (`tpEmis = 9`) | Implementar: emitir offline e transmitir em fila depois, dentro do prazo da legislação da UF |
| EPEC | Avaliar para NF-e como alternativa ao SVC |

`contigencia` na empresa passa a ter três valores: desligada, manual e automática. Cada entrada e saída
gera um evento auditável (quem, quando, por quê) e notificação.

### 3.5 Fila de envio (outbox)

Para o assíncrono deixar de bloquear a requisição: a nota entra numa coleção `fila_envio` com estado
(`pendente`, `enviada`, `aguardando_recibo`, `concluida`, `falha`). Um worker processa a fila,
consulta recibos e aplica a política. A API v2 ganha um endpoint de status
(`GET /api/v2/notas/{chave}`), e a legada continua síncrona.

### 3.6 Métricas

cStat por UF, latência p50/p95, retentativas, aberturas do circuit, tempo em contingência e notas
indeterminadas, via OpenTelemetry. Sem esses dados não há como medir se a IA ajuda.

## 4. Fases com IA

### Fase 1: diagnóstico de rejeições

**Problema:** o PDV recebe "Rejeição 778: Informado NCM inexistente" ou uma das centenas de rejeições
do leiaute, e o operador não sabe o que fazer.

**Solução:** quando a nota é rejeitada, um diagnóstico é gerado **fora do caminho da resposta**
(fila/worker) e anexado à nota:

```json
{
  "causaProvavel": "NCM 61091001 não existe na tabela vigente; o código correto para camiseta de algodão é 61091000",
  "campos": ["/NFe/infNFe/det[1]/prod/NCM"],
  "correcaoSugerida": "Alterar o NCM do item 1 para 61091000",
  "categoria": "cadastro_produto",
  "retentavel": false,
  "responsavel": "emissor",
  "confianca": 0.86
}
```

- **Entrada:** cStat, xMotivo, o trecho relevante do XML (com dados pessoais mascarados), o histórico de
  rejeições do mesmo emissor e uma base de conhecimento fixa (tabela de rejeições do Manual de
  Orientação, NTs vigentes, regras por UF).
- **Base de conhecimento em cache de prompt:** é grande e muda pouco, então vai no `system` com
  `cache_control`. As chamadas seguintes pagam ~5% do preço de entrada nessa parte.
- **Saída:** structured outputs com esquema JSON fixo (`output_config.format`), nunca texto livre.
- **Onde aparece:** campo `diagnostico` na API v2, tela de notas rejeitadas no painel e, opcionalmente,
  `xmotivo` estendido na API legada (com flag, para não quebrar PDVs).
- **Antes de ligar:** rodar em *shadow mode* sobre as rejeições já gravadas em `notas` (há histórico real
  no banco) e medir a taxa de acerto com uma avaliação (seção 6).

### Fase 2: validação pré-envio

Em duas camadas:

1. **Regras determinísticas (sempre, sem IA):** XSD do PL vigente (`Sefaz:DiretorioSchemas`),
   soma dos totais, CFOP × `idDest`, CST/CSOSN × CRT, NCM no formato, datas, CPF/CNPJ, chave × campos.
   Pega a maior parte das rejeições comuns em milissegundos.
2. **Revisão semântica por IA (opcional, por empresa):** incoerências que regra fixa não pega:
   descrição do produto incompatível com o NCM, CFOP de venda numa nota de devolução, `infCpl`
   contraditório, valores fora do padrão daquele emissor.

Cuidados com latência:

| Documento | Modo recomendado |
|---|---|
| **NFC-e (checkout)** | Só a camada determinística. A IA adiciona segundos e o cliente está na fila; no máximo, revisão assíncrona depois da autorização para aprender padrões |
| NF-e emitida no ERP | IA opcional antes do envio, com timeout (ex.: 8 s); se estourar, segue sem |
| Emissor novo ou primeiras N notas | IA ligada por padrão para pegar erros de cadastro cedo |

O resultado é uma lista de achados (`severidade`, `xpath`, `mensagem`, `sugestão`). Severidade
"bloqueante" só vem da camada determinística; a IA no máximo gera "alerta".

### Fase 3: conselheiro de contingência e retentativa

A Fase 0 resolve os casos claros. A IA entra nos **ambíguos**, que são os que hoje exigem alguém
olhando log:

- latência subindo em uma UF sem o circuit abrir;
- rejeições estranhas em série (ex.: 999 "erro não catalogado") que podem ser SEFAZ instável ou
  mudança de leiaute;
- status de serviço "em operação" mas envios falhando;
- uma UF passando a responder 103 a pedidos síncronos.

Um *avaliador de incidente* roda quando os sinais passam de um limiar. Com **ferramentas somente
leitura** (tool use), ele consulta:

| Ferramenta | Retorna |
|---|---|
| `obter_metricas_uf(uf, janela)` | cStat, latências, timeouts |
| `obter_status_servico(uf, modelo)` | Últimas consultas `NfeStatusServico` |
| `listar_rejeicoes_recentes(uf, limite)` | cStat + xMotivo agregados |
| `obter_estado_contingencia(uf)` | Empresas em contingência, desde quando |

A saída é uma recomendação estruturada:

```json
{
  "situacao": "SEFAZ-SP com latência p95 de 28 s nos últimos 10 min e 12% de timeouts; status de serviço ainda 107",
  "recomendacao": "entrar_contingencia",
  "abrangencia": { "uf": "SP", "modelo": 55 },
  "ajustes": { "timeoutMs": 45000, "envioAssincrono": true },
  "confianca": 0.72,
  "justificativa": "..."
}
```

**Quem executa:** a política determinística. A recomendação da IA só pode ser aplicada se:

- a ação estiver numa lista permitida (ajustar timeout, alternar síncrono/assíncrono, *propor*
  contingência);
- **entrar em contingência pede aprovação de um operador** (notificação no painel/e-mail/Teams com o
  resumo da IA e um botão), a menos que a regra determinística da Fase 0 já tenha decidido sozinha;
- ajustes automáticos expirarem sozinhos (ex.: 30 min) e voltarem ao padrão.

### Fase 4: análises em lote e assistente

- **Relatório diário** (Message Batches API, metade do custo, processamento assíncrono): agrupa as
  rejeições do dia por emissor/PDV/causa e aponta problemas recorrentes de cadastro ("o PDV 3 da loja X
  manda CFOP 5102 em devoluções").
- **Assistente no painel:** o operador pergunta "por que a nota 123 da loja 4 foi rejeitada?" e a IA
  responde usando as mesmas ferramentas somente leitura.

## 5. Arquitetura proposta

Segue a mesma regra do resto do sistema: a Application conhece uma porta; o provedor de IA fica na
Infrastructure.

```
Application
  Abstracoes/IAssistenteFiscal.cs
     DiagnosticarRejeicaoAsync(ContextoRejeicao)       → DiagnosticoRejeicao?
     RevisarDocumentoAsync(ContextoRevisao)           → IReadOnlyList<AchadoRevisao>
     AvaliarIncidenteAsync(ContextoIncidente)          → RecomendacaoIncidente?
  Resiliencia/ClassificadorFalhas.cs, PoliticaResiliencia.cs   (Fase 0, sem IA)

Infrastructure
  Ia/ClaudeAssistenteFiscal.cs        adaptador do SDK oficial da Anthropic para .NET
  Ia/BaseConhecimento/                tabelas de rejeição e NTs (versionadas, vão em cache de prompt)
  Ia/MascaramentoDados.cs             remove CPF/CNPJ de pessoa física, nomes e endereços do destinatário
  Ia/AssistenteFiscalNulo.cs          implementação "desligada" (padrão)
```

- **Desligada por padrão.** `Ia:Habilitada = false` registra o `AssistenteFiscalNulo`; nada muda no
  comportamento.
- Toda chamada passa por timeout + circuit breaker próprios; falha da IA = `null` e log, nunca exceção
  no fluxo fiscal.
- Diagnósticos e recomendações são gravados (coleção `ia_avaliacoes`) com entrada mascarada, saída,
  modelo, tokens e custo, para auditoria e avaliação.

### Esboço do adaptador (ilustrativo, não compilado)

Com o SDK oficial (`dotnet add package Anthropic`), usando cache de prompt na base de conhecimento e
saída estruturada:

```csharp
using System.Text.Json;
using Anthropic;
using Anthropic.Models.Messages;

internal sealed class ClaudeAssistenteFiscal(AnthropicClient cliente, IOptions<OpcoesIa> opcoes) : IAssistenteFiscal
{
    public async Task<DiagnosticoRejeicao?> DiagnosticarRejeicaoAsync(ContextoRejeicao contexto)
    {
        var resposta = await cliente.Messages.Create(new MessageCreateParams
        {
            Model = opcoes.Value.Modelo, // "claude-opus-5-5"
            MaxTokens = 4096,
            System = new List<TextBlockParam>
            {
                new() { Text = Instrucoes.Diagnostico },                                         // fixo
                new() { Text = BaseConhecimento.Rejeicoes, CacheControl = new CacheControlEphemeral() },
            },
            OutputConfig = new OutputConfig
            {
                Effort = Effort.Medium,
                Format = new JsonOutputFormat { Schema = Esquemas.Diagnostico },
            },
            // o XML vai mascarado e delimitado como dado, nunca como instrução
            Messages = [new() { Role = Role.User, Content = contexto.ParaPrompt() }],
        });

        if (resposta.StopReason == "refusal")
            return null;
        var json = resposta.Content.Select(b => b.Value).OfType<TextBlock>().FirstOrDefault()?.Text;
        return json is null ? null : JsonSerializer.Deserialize<DiagnosticoRejeicao>(json);
    }
}
```

Pontos de implementação a observar:

- **Modelo:** `claude-opus-5-5` (configurável em `Ia:Modelo`). Nesse modelo o raciocínio é sempre
  adaptativo e a profundidade é controlada por `effort` (padrão `medium`; vale medir `low` para
  diagnósticos simples e `high` para incidentes).
- **Ferramentas (Fase 3):** definidas com `strict: true` e escolha `auto` (esse modelo não aceita forçar
  uma ferramenta específica).
- **Recusas:** tratar `stop_reason == "refusal"` e habilitar o fallback do lado do servidor que a API oferece.
- **Erros:** tratar separadamente limite de taxa (429), 5xx e erro de requisição (`Anthropic.Exceptions`);
  o SDK já retenta 429/5xx duas vezes por padrão. Ajustar o timeout do cliente para o orçamento de cada uso.
- **Verificar o cache** em `Usage.CacheReadInputTokens`; se ficar zerado, algo variável entrou antes do
  ponto de cache (data, ID).

## 6. Como medir se funciona

1. **Conjunto de avaliação:** extrair do `nfeDb` as rejeições reais (cStat, xMotivo, XML mascarado) e,
   para uma amostra, anotar a causa e a correção certas (o que o emissor de fato mudou para autorizar).
2. **Métricas:** acerto da causa, utilidade da correção (avaliada por pessoa), taxa de "não sei" honesto
   e falsos alarmes na validação pré-envio.
3. **Shadow mode** em produção por algumas semanas: a IA gera, ninguém vê; compara-se com o que
   aconteceu de fato.
4. **Fase 3:** comparar as recomendações com as decisões do operador e com o que a política determinística
   faria. Automatizar um tipo de ação só quando a concordância for alta e o custo de erro for baixo.

## 7. Custos (ordem de grandeza)

Preços de lista do `claude-opus-5-5`: US$ 4 por milhão de tokens de entrada, US$ 20 por milhão de saída e
US$ 0,20 por milhão para leitura de cache.

Exemplo de diagnóstico: base de conhecimento de 10 mil tokens (cacheada), mais 2 mil tokens da nota e do
contexto, mais 800 tokens de resposta:

```
10.000 × 0,20/1M  = US$ 0,002   (cache)
 2.000 × 4/1M     = US$ 0,008   (entrada)
   800 × 20/1M    = US$ 0,016   (saída)
                    ≈ US$ 0,026 por diagnóstico
```

O custo cresce com o volume de **rejeições**, não de notas. Revisar toda nota antes do envio custa muito mais e
adiciona latência, por isso a Fase 2 recomenda a IA só em casos selecionados. O relatório diário via Batch
paga metade. Medir os tokens reais nas primeiras semanas e recalcular.

## 8. Privacidade e conformidade (LGPD)

- O XML tem dados pessoais do destinatário (CPF, nome, endereço, e-mail). **Mascarar antes de enviar**:
  a IA precisa de NCM, CFOP, CST e valores, não de quem comprou.
- Dados do emitente e da operação são sigilo comercial: formalizar o uso com o fornecedor (termos de
  retenção de dados) e registrar no inventário de tratamento da empresa.
- Habilitação por empresa (`Ia:EmpresasHabilitadas`) e opção de desligar totalmente.
- Log de auditoria do que foi enviado (já mascarado) e do que voltou.

## 9. Roteiro

| Fase | Entrega | Usa IA? | Depende de |
|---|---|---|---|
| **0** | Classificador de falhas, política Polly, circuit por UF, monitor de status, consulta antes de reenviar, métricas | Não | Migração em produção |
| **0b** | Contingência automática por regra, NFC-e offline, fila de envio | Não | Fase 0 |
| **1** | Diagnóstico de rejeições em shadow mode → no painel → na API | Sim | Métricas da Fase 0, conjunto de avaliação |
| **2** | Validação pré-envio (regras sempre + IA opcional para NF-e) | Parcial | XSD vigente, Fase 1 |
| **3** | Avaliador de incidentes com aprovação humana | Sim | Fases 0 e 1 |
| **4** | Relatório diário em lote, assistente no painel | Sim | Fase 1 |

**Recomendação:** começar pela Fase 0. Ela elimina a maior parte dos problemas de retentativa e
contingência sem custo de IA e produz os dados que as fases seguintes precisam para ser medidas.

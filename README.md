# Contador de Chamados

Registra chamados atendidos (Topdesk ou qualquer outra plataforma). Interface no navegador, dados salvos automaticamente em `chamados.json` **nesta pasta de rede** — qualquer computador do trabalho vê os mesmos chamados. Nenhum backup manual é necessário.

## Como abrir

Dê duplo clique em **`Abrir Contador.bat`**. O navegador abre sozinho em alguns segundos com tudo carregado — sem escolher arquivo, sem importar nada.

O `.bat` inicia um pequeno servidor local (PowerShell, já vem no Windows — nada é instalado) que grava os chamados direto no arquivo da rede a cada mudança. O rodapé da página mostra o estado:

- 🟢 Salvamento automático na rede — tudo certo.
- 🔴 Falha ao salvar — a rede caiu; os dados ficam guardados no navegador até voltar.
- 🟡 Aberto sem o `.bat` — funciona, mas salva só naquele navegador (um backup é baixado automaticamente 1× por dia como segurança).

## Como usar

1. Cole o número do chamado e aperte Enter.
2. O status inicial é **Em andamento** — depois atualize para **Aguardando solicitante**, **Resolvido** ou **Transferido** direto na lista.
3. Para lembrar de voltar num chamado, preencha "Agendar retorno" — quando vence, a linha fica vermelha, com bipe e notificação (ative uma vez no botão 🔔).
4. Números repetidos são avisados na hora; cada mês vira uma aba; a busca procura em todos os meses.

## 📄 Relatório do mês

O botão **"Relatório do mês"** gera um documento limpo só com as informações do mês da aba selecionada: resumo por status, chamados por dia e a lista completa. Dali você pode:

- **🖨 Salvar como PDF** — abre a impressão; escolha "Salvar como PDF".
- **⬇ Baixar Word** — baixa um `.doc` pronto para editar.

## Dados e backup (tudo automático)

- **Fonte única:** `chamados.json` nesta pasta de rede, atualizado a cada mudança (gravação atômica — nunca fica corrompido pela metade).
- **Backup diário automático:** antes da primeira gravação de cada dia, o estado anterior é copiado para `backups\chamados_AAAA-MM-DD.json`.
- **Restaurar um backup:** feche o navegador, copie o arquivo desejado de `backups\` por cima de `chamados.json` (renomeando), e abra de novo pelo `.bat`.
- Evite usar em dois computadores **ao mesmo tempo** — a última gravação vence.

## Arquivos

| Arquivo | Função |
|---|---|
| `Abrir Contador.bat` | Atalho para abrir o sistema |
| `server.ps1` | Servidor local que grava na rede (iniciado pelo .bat) |
| `index.html` | Interface |
| `chamados.json` | **Seus dados** (não apagar!) |
| `backups\` | Cópias diárias automáticas |

## Privacidade

`chamados.json`, `backups\` e os `chamados_*.json` não entram no repositório git — contêm dados reais de atendimento.

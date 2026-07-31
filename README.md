# Contador de Chamados

Página HTML local para registrar chamados atendidos (Topdesk ou qualquer outra plataforma), sem precisar de servidor, instalação ou internet — só abrir o `index.html` no navegador.

## Como usar

1. Abra `index.html` com duplo clique (ou arraste para o navegador).
2. Cole o número do chamado no campo e aperte Enter.
3. O status inicial é sempre **Em andamento** — depois você atualiza para **Aguardando solicitante**, **Resolvido** ou **Transferido de fila** direto na lista, quando souber o desfecho.
4. Se quiser ser lembrado de voltar num chamado, preencha "Agendar retorno" — ele aparece destacado em vermelho quando vence o prazo, com bipe sonoro e notificação do navegador (clique em "🔔 Ativar som e notificações" uma vez para habilitar).

## Contagem

Os cards no topo mostram o total de chamados — e o total separado por status — em quatro janelas: hoje, este mês, este ano e desde sempre.

## Dados e backup

- Tudo fica salvo no `localStorage` do navegador, neste computador. Não sincroniza entre máquinas.
- Um backup em JSON é baixado automaticamente uma vez por dia, ao adicionar o primeiro chamado do dia.
- Quando o mês vira, os chamados já **Resolvidos**/**Transferidos** são arquivados automaticamente (baixa um JSON com o mês fechado) e a lista some daquele mês; os que ainda estão **Em andamento** ou **Aguardando solicitante** continuam aparecendo, para nada ficar esquecido.
- Use "Importar Backup" para restaurar um arquivo `.json` salvo anteriormente.

Os arquivos de backup (`chamados_*.json`) não entram neste repositório — ficam só na máquina local, já que contêm dados reais de atendimento.

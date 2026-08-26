# Projeto: MiniFazenda (nome provisório)

## Contexto do desenvolvedor (importante)
- Não tenho formação em programação. Uso código por diversão, sem intenção de gerar renda com este projeto.
- Trabalho sozinho. Preciso de instruções diretas e claras, sem rodeios.
- Sempre me explique passo a passo quando algo precisar ser feito fora do Claude Code (instalar algo, configurar o Godot, exportar o jogo, etc).
- Não deduza escopo ou features que eu não pedi — se algo não estiver claro na documentação, me pergunte antes de implementar.
- Não gaste esforço/tokens implementando coisas grandes sem confirmar comigo antes. Prefira dar passos pequenos e verificáveis.

## O que é o projeto
Jogo estilo *point-and-click* de fazenda, inspirado na "MiniFazenda" do Facebook (~2014). Evitar semelhanças diretas com o jogo "Colheita Feliz".

A documentação completa de design está em `docs/design/`:
- `Descricao do jogo.md` — visão geral, mecânicas principais, estética, progressão, área/expansão, grid
- `Implementacoes extras.md` — quadro de pedidos de NPCs, modo offline/nuvem, customização de avatar, QoL (drag-to-plant, modo edição)
- `Itens e Decoracoes.md` — animais premium, habitats (galinheiro, chiqueiro, hara, estufa, celeiro), máquinas/veículos, consumíveis
- `Tabelas.md` — tabelas de plantações, árvores frutíferas e animais (custo, tempo, venda, XP) — **os tempos estão baseados em jogos antigos de Facebook e precisam ser revisados/rebalanceados para os padrões atuais**
- `Notas extras.md` — mecânicas adicionais do MiniFazenda original (energia, pragas, fazendas temáticas, maestria de cultivo)

Leia esses arquivos antes de propor qualquer implementação.

## Stack técnica
- Motor: **Godot 4.x**, renderer "Compatibility"
- Linguagem: **GDScript**
- Estética: 2D isométrico, grid rígido (1x1 = 1 bloco de terreno)
- Plataforma alvo inicial: **testar em web** (export HTML5 / GitHub Pages); alvo final: **PC/Steam**, exportado do mesmo projeto Godot

## Como trabalhar comigo
1. Antes de codar uma feature, resuma o que você entendeu que precisa ser feito e confirme comigo.
2. Depois de implementar algo, me diga como testar (ex: "aperte F5 no Godot" ou "rode isso no terminal").
3. Vá em passos pequenos — prefiro várias entregas pequenas e testáveis a uma grande de uma vez.

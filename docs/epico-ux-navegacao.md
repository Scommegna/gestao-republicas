# Épico — Reformulação de navegação e UX

> Rastreado pela issue **#42** (US09). Status: US-A, US-B, US-C, US-D e US-E
> implementadas na branch `feat/ux-navegacao-redesign`.

> Objetivo: melhorar o **fluxo de navegação** e o **design** do sistema, hoje
> sem navegação global e visualmente inconsistente (a tela de login é estilizada,
> mas o app autenticado usa Bootstrap puro e não tem barra de navegação).
>
> Premissa: priorizar fluxo e design — **pouca funcionalidade nova**, reaproveitando
> o modelo de dados e a identidade visual já existentes (paleta verde `#2D6A4F`,
> fontes Fraunces + DM Sans definidas na tela de login).

## Decisões de produto

- **Vínculo usuário ↔ república:** modelo de **membros**. Um usuário poderá
  **entrar** em uma república existente (não apenas ser dono). Isso exige um
  vínculo novo (User ↔ República) e entra junto com a US-B/US-C.
- **Branch/commits:** uma única branch de épico (`feat/ux-navegacao-redesign`)
  com commits semânticos por user story.
- **Ordem de entrega:** fundação primeiro (US-A + US-E), depois US-B, US-C e US-D.

## User Stories

### US-A — Navegação global e base de design  ✅ (1ª leva)
**Como** usuário autenticado,
**quero** uma barra de navegação consistente no topo de todas as telas (com home,
menu, perfil, configurações e sair),
**para** navegar pelo sistema sem ficar preso em uma tela.

Critérios de aceite:
- [x] Navbar fixa no topo, presente em todas as telas autenticadas.
- [x] Ícones de menu, perfil e configurações; ação de sair acessível.
- [x] Navbar **não** aparece nas telas de login/cadastro.
- [x] Identidade visual unificada (paleta, tipografia, cards) em todo o app.
- [x] Responsivo (menu recolhível no mobile).

### US-B — Tela inicial de repúblicas (usuário sem república)  ✅
**Como** usuário que ainda não participa de nenhuma república,
**quero** ver as repúblicas existentes, com busca e opção de criar a minha,
**para** encontrar e entrar em uma república ou criar a minha.

Critérios de aceite:
- [x] Se o usuário não participa de nenhuma república, exibe vitrine das existentes.
- [x] Cada república mostra nome, tipo (feminina/masculina/mista) e nº de moradores.
- [x] Campo de busca por nome.
- [x] Botão "criar república".
- [x] Ação de entrar/solicitar entrada em uma república (modelo de membros).

### US-C — Dashboard da república (usuário com república)  ✅
**Como** participante de uma república,
**quero** um painel da minha república com participantes, contas abertas e avisos,
**para** acompanhar a vida financeira e a organização da casa.

Critérios de aceite:
- [x] Lista de participantes (moradores ativos).
- [x] Contas/despesas em aberto.
- [x] Área de avisos (placeholder estático nesta fase; vira US própria depois).

### US-D — Divisão automática por morador  ✅
**Como** administrador da república,
**quero** que o sistema calcule e exiba automaticamente quanto cada morador deve
pagar de cada despesa,
**para** garantir a divisão justa entre os moradores ativos.

> Reconciliada com a PR #44 (já mergeada na `main`), que implementa a divisão
> criando um `Pagamento` por morador a cada despesa. Adotamos essa abordagem; o
> dashboard (US-C) soma esses pagamentos para mostrar o total devido por morador.

### US-E — Dados de demonstração (seeds)  ✅ (1ª leva)
**Como** time de desenvolvimento,
**quero** dados realistas pré-cadastrados,
**para** visualizar e demonstrar o sistema com conteúdo.

Critérios de aceite:
- [x] Campo `tipo` em `repúblicas` (feminina/masculina/mista).
- [x] Ao menos 5 repúblicas fictícias, com tipos variados.
- [x] Ao menos 5 moradores por república.
- [x] Seeds idempotentes (`bin/rails db:seed` pode rodar mais de uma vez).

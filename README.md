# 🏠 Gestão Financeira de Repúblicas

[![CI](https://github.com/Scommegna/gestao-republicas/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Scommegna/gestao-republicas/actions/workflows/ci.yml)
![Cobertura mínima 70% no app](https://img.shields.io/badge/cobertura-%E2%89%A570%25%20(linhas)-brightgreen)

Sistema web desenvolvido para auxiliar no **controle financeiro de repúblicas estudantis**, permitindo organizar despesas coletivas e calcular automaticamente os valores devidos por cada morador com base nos gastos totais da casa.

**CI:** [`/.github/workflows/ci.yml`](.github/workflows/ci.yml) executa Brakeman, Bundler Audit, Importmap audit, RuboCop e **RSpec com SimpleCov** (mínimo **70%** de cobertura de linhas em `app/`). Os comandos de instalação, Docker e testes estão na seção "Instalação e Execução".

---

# 1. 🎯 Objetivo

O objetivo deste projeto é facilitar a administração financeira de repúblicas, centralizando informações sobre contas e despesas compartilhadas, como:

- aluguel
- água
- energia elétrica
- internet
- compras coletivas
- manutenção geral
- demais gastos comuns

Com isso, o sistema permitirá:

- cadastro de moradores;
- registro de despesas mensais;
- dashboard administrativo com resumo financeiro;
- divisão automática de custos por morador;
- acompanhamento de pagamentos por morador;
- transparência financeira entre os integrantes da república.

## Dashboard administrativo

Após o login, o administrador é direcionado para o dashboard em `/dashboard`. A página consolida apenas os dados das repúblicas vinculadas ao usuário autenticado, exibindo:

- total de despesas do mês atual, calculado pela data de vencimento;
- total geral de despesas cadastradas;
- quantidade de moradores ativos;
- totais de pagamentos pagos e pendentes, calculados a partir dos pagamentos registrados;
- atalhos para cadastrar repúblicas, despesas, moradores e acompanhar pagamentos.

Quando não há repúblicas, moradores ou despesas cadastradas, o dashboard exibe mensagens orientando o próximo cadastro.

## Controle de pagamentos

Cada república possui uma tela de pagamentos em `/republicas/:republica_id/pagamentos`. Nela o administrador pode filtrar por mês e ano, visualizar os moradores ativos, conferir o valor devido por morador no período e registrar pagamentos vinculados a uma despesa específica.

O pagamento contém:

- morador responsável;
- despesa correspondente;
- valor pago;
- data do pagamento;
- status `Pago` ou `Pendente`.

Pagamentos parciais podem ser registrados como pendentes. O sistema impede valores zerados, negativos ou acima da cota do morador para a despesa. Um pagamento só pode ser marcado como pago quando a soma registrada para aquela despesa cobre a cota completa do morador.

Os totais de pagamentos alimentam o dashboard administrativo, exibindo quanto já foi pago e quanto permanece pendente no mês atual.

---

# 2. 👥 Integrantes e Responsabilidades

| Integrante | Responsabilidades |
|---|---|
| Lucas Scommegna | Configuração do repositório, CI/CD, autenticação (Devise/JWT), estrutura inicial do projeto |
| Alexandre Marques Spinola Cardoso | US04 — Cadastro de moradores (CRUD de residents vinculados a repúblicas, testes) |
| André Araújo Mendonça | US03 — Cadastro de repúblicas (CRUD completo com telas e testes) |
| Gustavo do Carmo Resende | US02 — Estilização das telas de login e cadastro |

## Responsabilidades (Sprint 1)

- **Lucas Scommegna**: setup inicial do projeto e autenticação (Devise), estrutura base (home/rotas), Bootstrap e ajustes de setup.
- **Gustavo do Carmo Resende**: estilização das telas de autenticação (login/cadastro/recuperação de senha).
- **André Araújo Mendonça**: CI (GitHub Actions) com suíte RSpec e qualidade (SimpleCov, specs de autenticação); implementação da US03 (CRUD de república) com testes.
- **Alexandre Marques Spinola Cardoso**: implementação do cadastro/listagem/edição de moradores (residents) com rotas/views e testes (PR #10).

---

# 3. 🛠️ Tecnologias Utilizadas

- Ruby
- Ruby on Rails
- Docker
- HTML / CSS / JavaScript
- Bootstrap
- Node.js
- SQLite

---

# 4. 🚀 Instalação e Execução

O projeto pode ser executado com Docker, sem instalar Ruby, Rails, Node.js ou SQLite diretamente na máquina. Para desenvolvimento local sem Docker, veja a seção "Execução sem Docker".

## Pré-requisitos

- Git
- Docker Engine ou Docker Desktop
- Docker Compose v2, disponível pelo comando `docker compose`

## Instalar Docker

### Ubuntu/Debian

Siga a documentação oficial do Docker para instalar o Docker Engine pelo repositório `apt`:

- https://docs.docker.com/engine/install/ubuntu/

Depois da instalação, verifique:

```bash
docker --version
docker compose version
```

Opcionalmente, para executar Docker sem `sudo`, siga o pós-instalação oficial:

- https://docs.docker.com/engine/install/linux-postinstall/

### Windows e macOS

Instale o Docker Desktop pela documentação oficial:

- Windows: https://docs.docker.com/desktop/setup/install/windows-install/
- macOS: https://docs.docker.com/desktop/setup/install/mac-install/

Depois de abrir o Docker Desktop, verifique no terminal:

```bash
docker --version
docker compose version
```

## Clonar o projeto

```bash
git clone git@github.com:Scommegna/gestao-republicas.git
cd gestao-republicas
```


## Atalhos Docker com `rep.sh`

O arquivo `rep.sh` cria o helper `rep` para simplificar os comandos Docker mais usados. Carregue o script no shell atual antes de usar:

```bash
source ./rep.sh
```

Depois disso, use:

```bash
rep build
```

Esse comando executa:

```bash
docker compose build
```

Para subir a aplicação, use:

```bash
rep run
```

Esse comando executa:

```bash
docker compose up
```

Também é possível executar o script diretamente sem carregar o helper:

```bash
./rep.sh build
./rep.sh run
```

## Build da imagem Docker

```bash
docker compose build
```

Também é possível construir a imagem diretamente pelo Docker:

```bash
docker build -t gestao-republicas .
```

## Subir a aplicação com Docker Compose

```bash
docker compose up
```

Para executar em segundo plano:

```bash
docker compose up -d
```

Acesse no navegador:

```bash
http://localhost:3000
```

O serviço `web` roda a aplicação Rails em modo `production` dentro do container e expõe a porta interna `80` na porta local `3000`.

## Comandos úteis com Docker

Ver logs:

```bash
docker compose logs -f web
```

Parar os containers:

```bash
docker compose down
```

Abrir um shell no container:

```bash
docker compose run --rm web bash
```

Abrir o console Rails:

```bash
docker compose run --rm web bin/rails console
```

Executar migrações/preparar banco manualmente:

```bash
docker compose run --rm web bin/rails db:prepare
```

Remover containers e o volume com o banco/arquivos persistidos:

```bash
docker compose down -v
```

## Rodar testes

### Com Docker

Com a imagem já construída, execute:

```bash
docker compose run --rm \
  -e RAILS_ENV=test \
  -e COVERAGE=true \
  -e CI=true \
  web bundle exec rspec
```

Para preparar explicitamente o banco de teste antes da suíte:

```bash
docker compose run --rm \
  -e RAILS_ENV=test \
  web bin/rails db:test:prepare
```

### Sem Docker

Instale as dependências locais do projeto:

```bash
bin/setup --skip-server
```

Execute a suíte RSpec com cobertura:

```bash
COVERAGE=true CI=true bundle exec rspec
```

Abrir o relatório HTML: `coverage/index.html`.

## Qualidade e segurança

Comandos usados no CI:

```bash
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit
bin/importmap audit
```

Para rodar todos os checks locais em sequência:

```bash
bin/ci
```

## Execução sem Docker

Caso prefira desenvolver diretamente na máquina, instale Ruby, Rails, Node.js, npm/yarn e SQLite compatíveis com o projeto. Depois rode:

```bash
bin/setup
```

O `bin/setup` instala dependências, prepara o banco e inicia o servidor de desenvolvimento via `bin/dev`.

Se quiser iniciar manualmente depois:

```bash
bin/dev
```

Acesse:

```bash
http://localhost:3000
```

# 5. Github Projects

https://github.com/users/Scommegna/projects/1

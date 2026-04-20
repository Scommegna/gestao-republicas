# 🏠 Gestão Financeira de Repúblicas

[![CI](https://github.com/Scommegna/gestao-republicas/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Scommegna/gestao-republicas/actions/workflows/ci.yml)
![Cobertura mínima 70% no app](https://img.shields.io/badge/cobertura-%E2%89%A570%25%20(linhas)-brightgreen)

Sistema web desenvolvido para auxiliar no **controle financeiro de repúblicas estudantis**, permitindo organizar despesas coletivas e calcular automaticamente os valores devidos por cada morador com base nos gastos totais da casa.

**CI:** [`/.github/workflows/ci.yml`](.github/workflows/ci.yml) executa Brakeman, Bundler Audit, Importmap audit, RuboCop e **RSpec com SimpleCov** (mínimo **70%** de cobertura de linhas em `app/`).

Rodar testes com relatório de cobertura localmente:

```bash
COVERAGE=true CI=true bundle exec rspec
```

Abrir o relatório HTML: `coverage/index.html`.

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
- divisão automática de custos por morador;
- acompanhamento de pagamentos;
- transparência financeira entre os integrantes da república.

---

# 2. 👥 Integrantes

- Lucas Scommegna
- Alexandre Marques Spinola Cardoso
- André Araújo Mendonça
- Gustavo do Carmo Resende

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

# 4. 🚀 Instruções de Instalação

## Pré-requisitos

Instalar:

- Ruby
- Ruby on Rails
- Node.js
- npm
- Git
- Docker

---

## Instalar Ruby (Linux Ubuntu/Debian)

```bash
sudo apt update
sudo apt install ruby-full
```

Verificar:

```bash
ruby -v
```

## Instalar Ruby On Rails

```bash
gem install rails
```

Verificar:

```bash
rails -v
```

## Instalar Node.js e NPM

```bash
sudo apt update
sudo apt install nodejs npm
```

Verificar:

```bash
node -v
npm -v
```

## Instalar Yarn

```bash
npm install -g yarn
```

Verificar:

```bash
yarn -v
```

## Clonar o projeto

```bash
git clone git@github.com:Scommegna/gestao-republicas.git
```

## Ir para a pasta

```bash
cd gestao-republicas
```

## Rodar setup

```bash
bin/setup
```

## Rodar o servidor

```bash
bin/rails server
```

Acesse no navegador:

```bash
http://localhost:3000
```

# 5. Github Projects

https://github.com/users/Scommegna/projects/1

# FastOrder API

[![Esteira DevSecOps](https://github.com/saviocunha/Pipeline_CI/actions/workflows/devsecops-pipeline.yml/badge.svg?branch=main)](https://github.com/saviocunha/Pipeline_CI/actions)

API REST simples desenvolvida em Python/Flask como parte dos estudos guiados da disciplina de Integração de Sistemas (UFCA):

- **Estudo Guiado 01 - Pipeline CI:** integração contínua (lint, testes e build Docker).
- **Estudo Guiado 02 - Pipeline DevSecOps:** segurança contínua, Feature Flags e release automatizado.

## 📖 Sobre o Projeto

A FastOrder API é um monolito de exemplo que demonstra, na prática, a construção de uma esteira de entrega contínua **segura**. A cada `push` ou `pull_request` na branch `main`, o GitHub Actions:

1. valida a qualidade do código (lint) e executa os testes automatizados;
2. varre o projeto em busca de segredos vazados, falhas no código e dependências vulneráveis;
3. constrói a imagem Docker e a escaneia em busca de vulnerabilidades;
4. publica a imagem no GitHub Container Registry (GHCR), **somente se todas as etapas anteriores passarem**.

Além disso, a API conta com uma **Feature Flag** que permite ativar ou desativar uma funcionalidade sem novo deploy.

## 🛠️ Tecnologias Utilizadas

- Python 3.12
- Flask
- pytest / pytest-flask
- flake8 (lint)
- Bandit (SAST)
- pip-audit (SCA)
- TruffleHog (Secret Scanning)
- Trivy (scan de imagem de contêiner)
- Docker
- GitHub Actions
- GitHub Container Registry (GHCR)

## 🚀 Como rodar localmente

```bash
# Clonar o repositório
git clone https://github.com/saviocunha/Pipeline_CI.git
cd Pipeline_CI

# Criar e ativar o ambiente virtual
python3 -m venv .venv
source .venv/bin/activate   # Linux/macOS
# .venv\Scripts\activate    # Windows

# Instalar as dependências
pip install -r requirements.txt

# Subir a aplicação
python3 app.py
```

A aplicação sobe em `http://localhost:5000`.

## 🧪 Como rodar os testes

```bash
pytest -v
```

A suíte cobre as rotas `/`, `/api/soma` e `/api/desconto`, esta última nos dois cenários da Feature Flag (ativada e desativada).

## 🚩 Feature Flag

A rota `/api/desconto` é protegida pela flag `FEATURE_DESCONTO_PROMO`, lida de uma variável de ambiente. O valor padrão é **desativado**, e a mudança de comportamento **não exige novo deploy nem rollback**: basta alterar a variável e reiniciar o contêiner.

| Valor da variável | Comportamento de `/api/desconto` |
|-------------------|----------------------------------|
| ausente ou `false` | Retorna `403` com `"flag_status": false` |
| `true` | Calcula o desconto e retorna `200` |

```bash
# Local, com a flag ativada
FEATURE_DESCONTO_PROMO=true python3 app.py

# Docker, com a flag ativada
docker run -d -p 5000:5000 -e FEATURE_DESCONTO_PROMO=true --name meu-backend fastorder-api:latest
```

O estado atual da flag pode ser consultado em `/api/status`.

## 🐳 Como rodar com Docker

```bash
# Construir a imagem
docker build -t fastorder-api:latest .

# Rodar o contêiner (flag desativada por padrão)
docker run -d -p 5000:5000 --name meu-backend fastorder-api:latest
```

Depois, acesse `http://localhost:5000/api/soma?a=5&b=7`.

> **Atenção:** pare o servidor local (`Ctrl+C`) antes de rodar o contêiner, pois ambos disputam a porta 5000.

Para usar a imagem já publicada pela esteira:

```bash
docker pull ghcr.io/saviocunha/fastorder-api:1.0.0
```

### Sobre o Dockerfile

- Usa a imagem base `python:3.12-slim`.
- Executa `apt-get update && apt-get upgrade -y` para aplicar os patches de segurança do sistema operacional (necessário para passar no scan do Trivy, por exemplo, para o pacote `zlib1g`).
- Copia o `requirements.txt` antes do código para aproveitar o cache de camadas do Docker.

## 🔌 Endpoints

| Método | Rota | Parâmetros | Exemplo de resposta |
|--------|------|------------|---------------------|
| GET | `/` | — | `{"mensagem": "Bem-vindo a API FastOrder!"}` |
| GET | `/api/status` | — | `{"status": "Operacional", "Serviço": "Fastorder-Web", "flags": {"desconto_promo": false}}` |
| GET | `/api/soma` | `a`, `b` (números) | `{"resultado": 12.0}` |
| GET | `/api/desconto` | `valor` (número > 0), `porcentagem` (número, padrão 10) | `{"valor_original": 100.0, "desconto_aplicado": "15.0%", "valor_final": 85.0}` |

Respostas de erro da rota `/api/desconto`:

- `403`: Feature Flag desativada.
- `400`: valor menor ou igual a zero, ou parâmetros inválidos.

## 🔐 Verificações de segurança locais

É possível executar cada verificação da esteira no terminal antes de fazer o commit:

```bash
# SAST: análise estática do código
bandit -r . -ll -ii

# SCA: vulnerabilidades nas dependências
pip-audit -r requirements.txt

# Scan da imagem Docker (requer o Trivy instalado)
docker build -t fastorder-api:latest .
trivy image fastorder-api:latest
```

## ⚙️ Pipeline DevSecOps

O workflow está definido em `.github/workflows/devsecops-pipeline.yml` e é acionado a cada `push` ou `pull_request` na branch `main`. Ele substitui a esteira simples do Estudo Guiado 01 e é composto por 4 jobs, em um runner `ubuntu-latest`:

| Job | Nome | Depende de | O que faz |
|-----|------|------------|-----------|
| 1 | Qualidade e Testes Funcionais | — | Checkout, Python 3.12, instalação das dependências, lint com flake8 e testes com pytest |
| 2 | Escaneamento de Segurança | — | **Secret Scanning** (TruffleHog), **SAST** (Bandit) e **SCA** (pip-audit), nessa ordem |
| 3 | Build Docker e Scan Trivy | Jobs 1 e 2 | Constrói a imagem local e a escaneia com o Trivy (falha se houver CVEs `CRITICAL` ou `HIGH` com correção disponível) |
| 4 | Build e Push Docker (Release) | Job 3 | Autentica no GHCR e publica a imagem `ghcr.io/<dono>/fastorder-api:1.0.0` |

```
lint-and-test ──┐
                ├──► docker-build-and-scan ──► docker-build-and-push
security-scans ─┘
```

### Quality Gates

Cada etapa funciona como uma porta de qualidade: se qualquer ferramenta encontrar um problema, os passos seguintes do job são interrompidos e os jobs dependentes não são executados. Como somente o job 4 tem permissão de escrita no registro (`packages: write`), **nenhuma imagem com código inseguro, dependências vulneráveis ou segredos vazados chega ao GHCR**.

Acompanhe as execuções na aba **Actions** do repositório no GitHub.

## 👥 Equipe

- Aldemir Ferreira da Silva Junior
- Beatriz Benigno de Vasconcelos
- Francisco Diogo de Sousa Silva
- Francisco Sávio Sousa da Cunha
- João Paulo Lima David

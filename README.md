# FastOrder API

API REST simples desenvolvida em Python/Flask como parte do **Estudo Guiado 01 - Pipeline CI** da disciplina de Integração de Sistemas (UFCA).

## 📖 Sobre o Projeto

A FastOrder API é um monolito de exemplo com três endpoints que demonstra, na prática, a construção de uma esteira de Integração Contínua (CI). A cada commit na branch `main`, o GitHub Actions automaticamente valida a formatação do código (lint), executa os testes automatizados e verifica se a imagem Docker compila sem erros.

## 🛠️ Tecnologias Utilizadas

- Python 3.9
- Flask
- pytest / pytest-flask
- flake8
- Docker
- GitHub Actions

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

## 🐳 Como rodar com Docker

```bash
# Construir a imagem
docker build -t fastorder-api:latest .

# Rodar o contêiner
docker run -d -p 5000:5000 --name meu-backend fastorder-api:latest
```

Depois, acesse `http://localhost:5000/api/soma?a=5&b=7`.

> **Atenção:** pare o servidor local (`Ctrl+C`) antes de rodar o contêiner, pois ambos disputam a porta 5000.

## 🔌 Endpoints

| Método | Rota | Parâmetros | Exemplo de resposta |
|--------|------|------------|---------------------|
| GET | `/` | — | `{"mensagem": "Bem-vindo a API FastOrder!"}` |
| GET | `/api/status` | — | `{"status": "Operacional", "Serviço": "Fastorder-Web"}` |
| GET | `/api/soma` | `a` (int), `b` (int) | `{"resultado": a+b}` |

## ⚙️ Pipeline de Integração Contínua

O workflow está definido em `.github/workflows/ci-pipeline.yml` e é acionado a cada `push` ou `pull_request` na branch `main`. A esteira executa, em um runner `ubuntu-latest` do GitHub:

1. **Checkout** do código-fonte.
2. **Configuração** do ambiente Python 3.9.
3. **Instalação** das dependências (`requirements.txt`).
4. **Validação estática (Lint)** com flake8.
5. **Testes automatizados** com pytest.
6. **Build da imagem Docker** para garantir que o contêiner compila.

Acompanhe as execuções na aba **Actions** do repositório no GitHub.

## 👥 Equipe

- Aldemir Ferreira da Silva Junior
- Beatriz Benigno de Vasconcelos
- Francisco Diogo de Sousa Silva
- Francisco Sávio Sousa da Cunha
- João Paulo Lima David

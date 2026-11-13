# Usa uma imgagem oficial do Python, bem leve (alpine ou slim)

FROM python:3.12-slim

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Atualiza pacotes do sistema operacional e limpa o cache do apt para reduzir o tamanho
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Atualiza as ferramentas base do Python 
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copia apenas o arquivo de dependências primeiro (otimização de cache do Docker)
COPY requirements.txt .

# Instala as dependências e atualiza TODOS os pacotes desatualizados do ambiente
RUN pip install --no-cache-dir -r requirements.txt \
    && pip list --outdated --format=json | python -c "import sys, json; print('\n'.join(p['name'] for p in json.load(sys.stdin)))" | xargs -r pip install --no-cache-dir --upgrade

# Copia o resto do código da aplicação para dentro do contêiner
COPY . .

# Expõe a porta 5000 para o mundo exterior
EXPOSE 5000

# Comando para rodar a aplicação quando o contêiner iniciar
CMD ["python", "app.py"]
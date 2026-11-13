# Usa uma imgagem oficial do Python, bem leve (alpine ou slim)

FROM python:3.9-slim

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

# Instala as dependências
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir --upgrade \
        "urllib3>=2.8.0" \
        "msgpack>=1.2.3" \
        "wheel>=0.46.2" \
        "jaraco.context>=6.1.0"

# Copia o resto do código da aplicação para dentro do contêiner
COPY . .

# Expõe a porta 5000 para o mundo exterior
EXPOSE 5000

# Comando para rodar a aplicação quando o contêiner iniciar
CMD ["python", "app.py"]
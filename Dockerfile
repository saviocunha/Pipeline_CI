# Usa uma imgagem oficial do Python, bem leve (alpine ou slim)

FROM python:3.9-slim
# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Atualiza pacotes do sistema operacional e limpa o cache do apt para reduzir o tamanho
# RUN apt-get update \
#     && apt-get upgrade -y --no-install-recommends \
#     && rm -rf /var/lib/apt/lists/*
# Copia apenas o arquivo de dependências primeiro (otimização de cache do Docker)
COPY requirements.txt .

# Atualiza as ferramentas base e todas as dependências da aplicação de uma vez
RUN pip install --no-cache-dir -r requirements.txt

# Copia o resto do código da aplicação para dentro do contêiner
COPY . .

# Expõe a porta 5000 para o mundo exterior
EXPOSE 5000

# Comando para rodar a aplicação quando o contêiner iniciar
CMD ["python", "app.py"]
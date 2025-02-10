# Etapa 1: Construção da aplicação
FROM node

# Diretório de trabalho dentro do contêiner
WORKDIR /app

# Copiar o package.json e o package-lock.json
COPY package*.json /app

# Instalar dependências
RUN npm install

COPY . /app

EXPOSE 3000

CMD ["npm", "start"]
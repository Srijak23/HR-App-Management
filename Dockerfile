#Identify the base image
FROM node:latest
#Set working directory
WORKDIR /app
#Copy the dependencies
COPY package*.json ./
#Install dependencies
RUN npm install
#Copy the complete source code into the docker image
COPY . .
#Expose port number
EXPOSE 3001
#Run your application
CMD ["npm","start"]
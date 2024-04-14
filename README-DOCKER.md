# Deploy Using Docker

## How to Deploy
1. Make sure the .env file exists 
2. Deploy using docker-compose up commmand
```shell
docker-compose build
docker-compose up -d
```
3. Check running containers using docker-compose ps
```shell
docker-compose ps -a
```
4. Access application using ip address docker host and application port
```text
http://<IPAddress>:<ApplicationPort>
```

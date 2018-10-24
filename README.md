# phila.gov-docker-dev
Phila.gov local development environment using Docker Containers

## Required
- **An AWS account with the City Of Phildelphia**
- Docker
- Git

## How to use
- Clone this repository
- Go to _phila.gov-docker-dev_ (`cd phila.gov-docker-dev`) and delete the _.git_ folder (`rm -r .git`)
- Rename the _.env.sample_ file to _.env_ (`mv .env.sample .env`) and set your AWS City of Phildelphia account credentials, and the developer database path.
- Execute `docker-compose up --build` for the first time, if you aready build the docker image, you should use `docker-compose up` only.
- When the docker compose installer finishes, go to `https://localhost:8080` in your broswer.

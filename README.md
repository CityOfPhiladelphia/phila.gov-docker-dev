# phila.gov-docker-dev
Phila.gov local development environment using Docker Containers

## Required
- Docker
- Git
- An AWS account with the City of Philadelphia (Or download the phila.gov database sql dump and save it into **_db-data/_**)

## How to use
- Clone this repository
- Run `cd phila.gov-docker-dev` and delete the **_.git_** folder (`rm -r .git`)
- Run `docker-compose up`
- Browse `https://localhost:8080`

## Note
If you have AWS Cli credentials, rename the `.env.sample` file to `.env` and replace the required environment variables

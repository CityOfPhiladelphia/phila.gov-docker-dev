# phila.gov-docker-dev
Phila.gov local development environment using Docker Containers

## Important!
This new version WILL CREATE a new IMAGE. Please refer to _remove docker images_ on Google (or your internet search provider) if you want to clean old unused docker images.


## Required
- **An AWS account with the City Of Phildelphia**
- Docker
- Git

## How to use
- Clone this repository
- Go to _phila.gov-docker-dev_ (`cd phila.gov-docker-dev`) and delete the _.git_ folder (`rm -r .git`)
- Rename the _.env.sample_ file to _.env_ (`mv .env.sample .env`) and set your AWS City of Phildelphia account credentials, and the developer database path.
- You must execute `docker-compose run --service-ports philagov`, do not forget the `--service-ports` flag, this is mandatory for this service to work correctly. If you run `docker-copmose up` instead, please open a new shell and run `docker exec -it [name_of_your_philagov_container] /bin/bash` and then run `scripts/mysql-config.sh`; This will initiate the step by step service to download and install the database.
- When the docker compose installer finishes, go to `https://localhost:8080` in your broswer.
- If you want to develop locally with a valid SSL certificate, check the README file in `/nginx/certs`.

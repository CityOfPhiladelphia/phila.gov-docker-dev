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

## Local SSL
1 - Run the following command to generate a [self-signed certificate](https://letsencrypt.org/docs/certificates-for-localhost/).
```
openssl req -x509 -out localhost.crt -keyout localhost.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
   ```
2 - Move the localhost.key and localhost.cnf to the repo's location on your machine inside `/nginx/certs/` 

3 - Trust your own certficate. 
  * On a Mac -  `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain localhost.crt` or manually through Keychain Access

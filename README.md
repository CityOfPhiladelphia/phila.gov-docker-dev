# phila.gov-docker-dev
Phila.gov local development environment using Docker Containers


## Required
- **An AWS account with the City Of Phildelphia** - Contact another developer for access to our AWS account. 
- Docker
- Git

## Setting up local dev
1. Clone this repository
2. `cd phila.gov-docker-dev` and delete the _.git_ folder `rm -r .git` and the _.gitignore_ file `rm -r .gitignore`
3. Rename the _.env.sample_ file to _.env_ and set your AWS City of Phildelphia account credentials. Get your access keys from the IAM settings in your AWS user profile. To set the other values, login to LastPass and look for `phila.gov enviornment file (env)`
4. If this is the first time you are setting up phila.gov for local development, first run `docker build . -t philagov:latest` to create the latest version of the image.
5. Execute the script *install.sh* `./install.sh`.
6. When the docker compose installer finishes, go to `https://localhost:[port]` in your broswer. The **port** will the printed in your console as **Web Port: #####** The default port is 19107.
-- If you forget the web port, you can open a new tab in your console and run `docker ps`.

`
Note: to develop against phila-standards, add the standards repo to the root of this project directory and name the standards folder phila-standards.
`

### Restarting the docker server
- Start the images
  - ``docker start [Database Image Name]``
  - ``docker start -i [Philagov Image Name]``

## NOTES:
- If you use `-i` you will now know when the container is running and _ready to handle connection_, no need to run **supervisor** anymore, the `entrypoints.sh` runs it for you.

- The new version of this repo will create a new image. Refer to the (Docker documentation)[https://docs.docker.com/engine/reference/commandline/image_rm/] if you want to remove old docker images.

### SSL certificate
If you want to develop locally with a valid SSL certificate, you'll need to trust the certficate that was created when you created the docker image.

On a Mac, cd into /nginx/certs/ directory and run `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain localhost.crt`. 

You can also trust the certificate manually through Keychain Access in settings.

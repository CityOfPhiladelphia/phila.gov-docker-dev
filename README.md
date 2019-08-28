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
- You must execute the script *install.sh* `./install.sh`.
- When the docker compose installer finishes, go to `https://localhost:[port]` in your broswer. The **port** will the printed in your console as **Web Port: #####**
-- If you forget web port, you can open a new tab in your console and run `docker ps`, port number will be part of the containe's name.

### How To Restart Server
- Start the images
  - ``docker start [Database Image Name]``
  - ``docker start -i [Philagov Image Name]``

## NOTE:
if you use `-i` you will now know when the container is running and _ready to handle connection_, no need to run **supervisor** anymore, the `entrypoints.sh` runs it for you.

### SSL certificate
If you want to develop locally with a valid SSL certificate, you'll need to trust the certficate that was created when you created the docker image.

On a Mac, cd into /nginx/certs/ directory and run `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain localhost.crt`. 

You can also trust the certificate manually through Keychain Access in settings.

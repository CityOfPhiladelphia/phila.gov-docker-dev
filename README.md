# Phila.gov Docker Dev

Phila.gov local development environment using Docker Containers

## Getting Started

This will create a new Docker IMAGE. Please refer to _remove docker images_ on Google (or your internet search provider) if you want to clean old unused docker images.

### Prerequisites

- **An AWS account with the City Of Phildelphia** - Contact another developer for access to our AWS account. 
- <a href="https://www.docker.com/products/docker-desktop">Docker</a>
- <a href="https://desktop.github.com/">Git</a>

### Installing - Setting up local dev
1. Clone this repository
2. `cd phila.gov-docker-dev` and delete the _.git_ folder and the _.gitignore_ file 
```
rm -r .git .gitignore
```
3. Rename the _.env.sample_ file to _.env_ and set your AWS City of Phildelphia account credentials, by accessing the "Command line or programmatic access" modal for the AWS account you want to launch to. Replace the values with your session tokens.
To set the other values, login to LastPass and look for `phila.gov environment file (env)`
4. If this is the first time you are setting up phila.gov for local development, run `docker build . -t philagov:latest` to create the latest version of the image.
5. Clone the latest version of the phila.gov repo into the root of the docker-dev project. 
```
git clone https://github.com/CityOfPhiladelphia/phila.gov.git
```
6. Follow the [instructions on phila.city](https://phila.city/display/appdev/Database+Dump+Instructions) to get a fresh copy of the database.
7. Execute the script *install.sh* `./install.sh`.
8. When the docker compose installer finishes, go to `https://localhost:[port]` in your broswer. The **port** will the printed in your console as **Web Port: #####** The default port is 19107.
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

## Deployment

1. Setting SSL Certificate
  - If you want to develop locally with a valid SSL certificate, you'll need to trust the certficate that was created when you created the docker image.
  - On a Mac, cd into /nginx/certs/ directory and run `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain localhost.crt`. 
2. Setting User Info
  - confirm that the .env is set correctly with values for the following:
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - AWS_DEFAULT_REGION
    - GOOGLE_CALENDAR
    - PHILA_DB_PATH
    - PHILA_DB_FILE
    - SWIFTYPE_ENGINE
    - AQI_KEY
    - JWT_AUTH_SECRET_KEY
    - FONTAWESOME_NPM_AUTH_TOKEN
3. Start the images
  - ``docker start [Database Image Name]``
  - ``docker start -i [Philagov Image Name]``
4 Automatically starting images on docker boot up
  - get list of active Docker containers by running `docker ps`
  - ``docker update --restart=always [Database Image CONTAINER ID]``
  - ``docker update --restart=always [Philagov Image CONTAINER ID]``


## License
This project is licensed under the MIT License - see the LICENSE.md file for details

### SSL certificate

You can also trust the certificate manually through Keychain Access in settings.

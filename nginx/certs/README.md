# SSL certificate
You'll need to trust the certficate that was created when you created the docker image.

On a Mac, cd into this directory and run `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain localhost.crt`. 
You can also trust the certificate manually through Keychain Access in settings.

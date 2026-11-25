# nginx-flask-proxy

Option 1: Secure Web Application.

Nginx sits in front of a Flask app. Terraform creates both containers and one user-defined Docker network. Only Nginx is published, on `127.0.0.1:8080`. Flask has no host port. Nginx reaches it by the container name `flask`, not by an IP address.

The Nginx config is bind-mounted from this repo. That file is what turns Nginx into the reverse proxy.

Deploy, test, and destroy commands will be added once the Terraform configuration is in place.

# nginx-flask-proxy

Option 1: Secure Web Application.

Nginx sits in front of a Flask app. Terraform creates both containers and one user-defined Docker network. Only Nginx is published, on `127.0.0.1:8080`. Flask has no host port. Nginx reaches it by the container name `flask`, not by an IP address.

The Nginx config is bind-mounted from `nginx/nginx.conf`. That file is what turns Nginx into the reverse proxy.

## Deploy

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Test

```bash
docker ps
docker network inspect nginx-flask
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/health
terraform plan
```

`docker ps` should show `nginx` on `127.0.0.1:8080->80/tcp` and `flask` with no host port. Both names should appear in the `nginx-flask` network. `/` returns `flask ok`. `/health` returns `{"status":"ok"}`. The second `terraform plan` should report no changes.

## Destroy

Collect the test output above before destroying.

```bash
terraform destroy
```

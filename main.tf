terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.7.0"
    }
  }
}

# Uses the local Docker Desktop socket. No cloud credentials.
provider "docker" {}

# User-defined network so containers can reach each other by name.
# The default bridge network does not provide that DNS.
resource "docker_network" "app" {
  name = "nginx-flask"
}

# Built from app/. Terraform owns the image so apply can recreate it.
resource "docker_image" "flask" {
  name         = "flask-health:latest"
  keep_locally = true

  build {
    context            = "${path.module}/app"
    dockerfile         = "Dockerfile"
    use_legacy_builder = true
  }

  # Rebuild only when the app files change, so a second plan stays empty.
  triggers = {
    app_sha1 = sha1(join("", [
      filesha1("${path.module}/app/app.py"),
      filesha1("${path.module}/app/Dockerfile"),
      filesha1("${path.module}/app/requirements.txt"),
    ]))
  }
}

# Name must stay "flask". Nginx forwards to that name.
# No ports block: Flask is not published on the host.
resource "docker_container" "flask" {
  name  = "flask"
  image = docker_image.flask.image_id

  networks_advanced {
    name = docker_network.app.name
  }
}

# Pulled, not built. The proxy behavior comes from the bind-mounted config.
resource "docker_image" "nginx" {
  name         = "nginx:1.27-alpine"
  keep_locally = true
}

# Only published container. Host port 8080 is bound to 127.0.0.1, not 0.0.0.0.
resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.image_id

  # Flask must exist first so the name "flask" resolves on the network.
  depends_on = [docker_container.flask]

  networks_advanced {
    name = docker_network.app.name
  }

  ports {
    internal = 80
    external = 8080
    ip       = "127.0.0.1"
    protocol = "tcp"
  }

  # Absolute host path so a later plan does not see a different mount source.
  mounts {
    type      = "bind"
    source    = abspath("${path.module}/nginx/nginx.conf")
    target    = "/etc/nginx/conf.d/default.conf"
    read_only = true
  }
}

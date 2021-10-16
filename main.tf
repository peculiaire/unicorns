terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "unicorn" {
  name         = "peculiaire/smartdm:latest"
  keep_locally = false
}

resource "docker_container" "unicorn" {
  image = docker_image.unicorn.latest
  name  = "unicorns"
  ports {
    internal = 8080
    external = 8080
  }
}


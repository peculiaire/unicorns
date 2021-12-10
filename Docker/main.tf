terraform {
}

provider "docker" {
}

resource "docker_image" "unicorn" {
  name         = "peculiaire/strongdm:latest"
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


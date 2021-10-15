# Notes on making these unicorns fly

I opted to run in a docker container, because I didn't really know as much as I should about running in docker and it seemed more fun than running it in a whole VM on its own.

It's pushed to DockerHub here: <https://hub.docker.com/repository/docker/peculiaire/smartdm>

I discovered the joys of Go's `GO111MODULE` option, because I had to use it to actually build the Unicorn Go module into the Dockerfile. 

Todo:

* Terraform
* Load Balancer
* DNS
* Autoscaling

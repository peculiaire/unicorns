# Notes on making these unicorns fly

This is for my SmartDM take home: <https://docs.google.com/presentation/d/1L8k9vmmxDsNsKtakT8TCZMyCvSvTEuyyhLHkXND1_nA/edit?usp=sharing>

## Todo

* Confirm Go app runs (unicorns!) ✅
* Make Docker container ✅
* Terraform 🐝
* Load Balancer ❌
* DNS ❌
* Autoscaling ❌

## Notes

### Friday, Oct 15

I opted to run in a Docker container, because I didn't really know as much as I should about running in Docker and it seemed more fun than running it in a whole VM on its own.

It's pushed to DockerHub here: <https://hub.docker.com/repository/docker/peculiaire/smartdm>

I discovered the joys of Go's `GO111MODULE` option, because I had to use it to actually build the Unicorn Go module into the Dockerfile.

I haven't used Terraform before, because I usually use Cloudformation, but I want to learn it so I'm using it here. We'll see how it plays with my personal AWS account.

Done today: Got through getting the Go app installed locally, confirming it works, making a Dockerfile for it and getting a Docker image uploaded to DockerHub, installing Terraform and got it running my Docker image on my localhost. Fun!

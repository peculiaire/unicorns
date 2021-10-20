# Notes on making these unicorns fly

This is for my SmartDM take home: <https://docs.google.com/presentation/d/1L8k9vmmxDsNsKtakT8TCZMyCvSvTEuyyhLHkXND1_nA/edit?usp=sharing>

## Todo

* Confirm Go app runs (unicorns!) ✅
* Make Docker container ✅
* Terraform ✅
* Load Balancer 🐝
* DNS ❌
* Autoscaling ❌

## Notes

### Friday, Oct 15

I opted to run in a Docker container, because I didn't really know as much as I should about running in Docker and it seemed more fun than running it in a whole VM on its own.

It's pushed to DockerHub here: <https://hub.docker.com/repository/docker/peculiaire/smartdm>

I discovered the joys of Go's `GO111MODULE` option, because I had to use it to actually build the Unicorn Go module into the Dockerfile.

I haven't used Terraform before, because I usually use Cloudformation, but I want to learn it so I'm using it here. We'll see how it plays with my personal AWS account.

Done today: Got through getting the Go app installed locally, confirming it works, making a Dockerfile for it and getting a Docker image uploaded to DockerHub, installing Terraform and got it running my Docker image on my localhost. Fun!

### Sunday, Oct 17

Looking into how to run Terraform and use it to start up a Fargate cluster, I found this useful article: <https://section411.com/2019/07/hello-world/>

Right now I know how to do all this in CloudFormation, but it's a pain! And I have been wanting to learn how to use Terraform anyways.

I'm interested in Fargate as well, because I could host my containers on instances behind a load balancer, but I would rather have AWS manage that. Time to learn more new stuff.

### Monday, Oct 18

Didn't get much done yesterday, because I couldn't run Terraform init for AWS, which turned out to be a DNS issue on my home network. :/

That's now fixed.

I'm working through the tutorial (and loving it, because Cloudformation is painful!)

### Tuesday, Oct 19

Trying to find the best way to demonstrate the unicorns via curl, and figured this out:

`curl --trace - http://<loadbalancer>`

I'm trying to keep the wait time to unicorn (TTU) low, and the buffers in web browsers and cURL are fighting me.

On the bright side I'm getting quite comfortable translating CloudFormation -> Terraform, and I'm better at reading Go. I'm not sure if I would choose Fargate often, but I appreciate any time I don't have to handle service management and I'm willing to deal with some restrictions and config quirks to use it.

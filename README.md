# Notes on making these unicorns fly

This is for my StrongDM take home: <https://docs.google.com/presentation/d/1L8k9vmmxDsNsKtakT8TCZMyCvSvTEuyyhLHkXND1_nA/edit?usp=sharing>

App: <http://unicorns-lb-192830076.us-east-2.elb.amazonaws.com>

Demo: `curl --trace - http://unicorns-lb-192830076.us-east-2.elb.amazonaws.com`

## Todo

-   Confirm Go app runs (unicorns!) ✅
-   Make Docker container ✅
-   Terraform ✅
-   Load Balancer ✅
-   Autoscaling ✅
-   Monitoring 📈

-   DNS + TLS ❌ (punted because I do not want to host this in my own DNS)

## Notes

I worked on this a little bit a day, as other life stuff permitted. My goals were:

1. demonstrate I know how to run a service from scratch
1. have fun and learn something

### Friday, Oct 15

I opted to run in a Docker container, because I didn't really know as much as I should about running in Docker and it seemed more reasonable for a small app than running it in a whole VM on its own.

It's pushed to DockerHub here: <https://hub.docker.com/repository/docker/peculiaire/strongdm>

I discovered the joys of Go's `GO111MODULE` option, because I had to use it to actually build the Unicorn Go module into the Dockerfile.

I haven't used Terraform before, because I usually use Cloudformation written with JSON at my current job, but I want to learn it so I'm using it here. We'll see how it plays with my personal AWS account.

Done today: Got through getting the Go app installed locally, confirming it works, making a Dockerfile for it and getting a Docker image uploaded to DockerHub, installing Terraform and got it running my Docker image on my localhost. Fun!

### Sunday, Oct 17

Looking into how to run Terraform and use it to start up a Fargate cluster, I found this useful article: <https://section411.com/2019/07/hello-world/>

Right now I know how to do all this in CloudFormation, but it's a pain! And I have been wanting to learn how to use Terraform anyways.

I'm interested in Fargate as well, because I could host my containers on instances behind a load balancer, but I would rather have AWS manage that. Time to learn more new stuff.

### Monday, Oct 18

Didn't get much done yesterday, because I couldn't run Terraform init for AWS, which turned out to be a DNS issue on my home network. :/

That's now fixed.

I'm working through the tutorial (and loving it, relative to CloudFormation, because CloudFormation is painful!)

### Tuesday, Oct 19

Trying to find the best way to demonstrate the unicorns via curl, and figured this out:

`curl --trace - http://<loadbalancer>`

I'm trying to keep the wait time to unicorn (TT🦄) low, and the buffers in web browsers and curl and probably the Amazon load balancer are fighting me.

On the bright side I'm getting quite comfortable translating CloudFormation -> Terraform, and I'm better at reading Go. I'm not sure if I would choose Fargate often, but I appreciate any time I don't have to handle service management and I'm willing to deal with some restrictions and config quirks to use it.

### Wednesday, Oct 20

DNS + TLS: if I was going to deploy this to production for real, I would do the following things:

1. I'd have a domain I was willing to pay for (ie, jscharmen.com)
1. I'd probably set up the nameservers to point to Route53 if I'm going all in on AWS
1. I'd point an Amazon Certificate to a subdomain, or to a wildcard domain in my domain (ie, \*.jscharmen.com)
1. I would use that ACM certificate in my ALB listener on port 443, which would point to the Fargate container cluster on port 8080

Security: I'm operating in the AWS ecosystem here, which means security comes down to a few things:

1. Security groups: only open those ports to the world that you want to open to the world
2. IAM roles: scope them as tightly to what you need as possible (obviously StrongDM helps with this!)

Monitoring: I'm firmly in the "less is more" camp for monitoring; I want to be able to know if a service is running within its stated SLA, but I do not want to see noisy alerts that cannot be acted on.

1. This app doesn't have any logging, which would probably be something we should fix for production. We want to at least see errors, and we should ideally have logs in a central place that is searchable.
1. We should also think about metrics that are useful to understand how the service is running (observability). This can be metrics, tracing, instrumentation with sampling... it really depends on the service itself.
1. We should probably have a canary-type check to see if it's reachable within the Service Level Objective we have set internally, and definitely within any Service Level Agreement settled on with customers.
1. That canary check should trigger some action to improve the situation if it fails: that could be automated or paging an engineer to see what happened.
1. The service should have documentation to allow new, sleepy, or unfamiliar engineers to deal with issues as needed.
1. We should have a status page to report known outages or degradation of service with customers.

Autoscaling: I added an autoscaling policy: min 1 container, max 5, and the trigger is 75% CPU threshold. Of course in the real world autoscaling can be tricky to set up, considering the capacity of other systems that might feed into any given system, or take output from it, and depending on how the service to be autoscaled uses its compute resources!

# Make an ECS cluster (which will host our app, unicorns)
resource "aws_ecs_cluster" "app" {
  name = "app"
}

# Put the ECS service up, in the cluster, using Fargate
resource "aws_ecs_service" "unicorns" {
  name            = "unicorns"
  task_definition = aws_ecs_task_definition.unicorns.arn
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"
  desired_count   = 1

  # all this stuff is in the VPC we're creating
  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_unicorns.id,
    ]

    subnets = [
      aws_subnet.private.id,
    ]
  }

  # we'll need to run this behind a load balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.unicorns.arn
    container_name   = "unicorns"
    container_port   = "8080"
  }
}

# logs logs logs, though this service doesn't really log.

resource "aws_cloudwatch_log_group" "unicorns" {
  name = "/ecs/unicorns"
}

# ECS task definition: more details

resource "aws_ecs_task_definition" "unicorns" {
  family = "unicorns"

  container_definitions = file("containerdef.json")

  execution_role_arn = aws_iam_role.unicorns_task_execution_role.arn


  # These are the minimum values for Fargate containers.
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  # This is required for Fargate containers (more on this later).
  network_mode = "awsvpc"
}

# Oh dear now we have to make IAM roles, gah

resource "aws_iam_role" "unicorns_task_execution_role" {
  name               = "unicorns-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Normally we'd prefer not to hardcode an ARN in our Terraform, but since this is
# an AWS-managed policy, it's okay. (I stole this line from the tutorial but I'm leaving it here)
data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach the above policy to the execution role.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.unicorns_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

# ok ok ok now we need a load balancer to run the cluster behind. 
# I am really not sure if that health check will work, but we will see

resource "aws_lb_target_group" "unicorns" {
  name        = "unicorns"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.app_vpc.id

  health_check {
    enabled = true
    path    = "/"
  }

  depends_on = [aws_alb.unicorns]
}

resource "aws_alb" "unicorns" {
  name               = "unicorns-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public.id,
    aws_subnet.private.id,
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.egress_all.id,
  ]

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "unicorns_http" {
  load_balancer_arn = aws_alb.unicorns.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.unicorns.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.unicorns.dns_name}"
}

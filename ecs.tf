# Make an ECS cluster (which will host our app, unicorns)
resource "aws_ecs_cluster" "app" {
  name = "app"
}

# Put the ECS service up, in the cluster, using Fargate
resource "aws_ecs_service" "unicorns_ecs" {
  name            = "unicorns-ecs"
  task_definition = "aws_ecs_task_definition.unicorns_ecs.arn"
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"

  # all this stuff is in the VPC we're creating
  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_api.id,
    ]

    subnets = [
      aws_subnet.private.id,
    ]
  }

  # we'll need to run this behind a load balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.unicorns_api.arn
    container_name   = "unicorns-api"
    container_port   = "8080"
  }

  # oh I guess we need to tell it to RUN A CONTAINER (at least 1 of them)
  desired_count = 1
}

# logs logs logs, though this service doesn't really log.

resource "aws_cloudwatch_log_group" "unicorns_ecs" {
  name = "/ecs/unicorns-ecs"
}

# ECS task definition: more details

resource "aws_ecs_task_definition" "unicorns_ecs" {
  family = "unicorns-ecs"

  container_definitions = <<EOF
  [
    {
      "name": "unicorns-api",
      "image": "peculiaire/smartdm:latest",
      "portMappings": [
        {
          "containerPort": 8080
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "us-east-2",
          "awslogs-group": "/ecs/unicorns-ecs",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  EOF

  execution_role_arn = aws_iam_role.unicorns_api_task_execution_role.arn


  # These are the minimum values for Fargate containers.
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  # This is required for Fargate containers (more on this later).
  network_mode = "awsvpc"
}

# Oh dear now we have to make IAM roles, gah

resource "aws_iam_role" "unicorns_api_task_execution_role" {
  name               = "unicorns-api-task-execution-role"
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
  role       = aws_iam_role.unicorns_api_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

# ok ok ok now we need a load balancer to run the cluster behind. 
# I am really not sure if that health check will work, but we will see

resource "aws_lb_target_group" "unicorns_api" {
  name        = "unicorns-api"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.app_vpc.id

  health_check {
    enabled = true
    path    = "/"
  }

  depends_on = [aws_alb.unicorns_api]
}

resource "aws_alb" "unicorns_api" {
  name               = "unicorns-api-lb"
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

resource "aws_alb_listener" "unicorns_api_http" {
  load_balancer_arn = aws_alb.unicorns_api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.unicorns_api.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.unicorns_api.dns_name}"
}

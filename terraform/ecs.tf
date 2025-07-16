resource "aws_ecs_cluster" "main" {
  name = "simpletime-cluster"
}

resource "aws_ecs_task_definition" "simpletime" {
  family                   = "simpletime-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "simpletime"
    image = "surajchauhan2310/simpletimesvc:latest"
    portMappings = [{ containerPort = 5000, hostPort = 5000 }]
  }])
}

resource "aws_ecs_service" "simpletime" {
  name            = "simpletime-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.simpletime.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "simpletime"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.app_listener]
}

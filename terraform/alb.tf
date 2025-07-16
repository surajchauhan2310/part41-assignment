resource "aws_lb" "app" {
  name               = "ecs-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "ecs-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

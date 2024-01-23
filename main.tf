#Server 1 creation in subnet 1
resource "aws_instance" "webserver1" {
  ami                    = "ami-0d980397a6e8935cd"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.SG.id]
  subnet_id              = aws_subnet.private-subnets["subnet-1"].id
 
}

#server2 creation in subnet 2
resource "aws_instance" "webserver2" {
  ami                    = "ami-0d980397a6e8935cd"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.SG.id]
  subnet_id              = aws_subnet.private-subnets["subnet-2"].id
  
}

#creation of application load balancer and add both subnets to route application traffic
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.SG.id]
  subnets         = [aws_subnet.private-subnets["subnet-1"].id, aws_subnet.private-subnets["subnet-2"].id]

  tags = {
    Name = "web"
  }
}

#Traget group for ALB
resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
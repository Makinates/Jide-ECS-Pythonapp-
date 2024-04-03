# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/20"
  tags = {
    Name = "PyAPP VPC"
  }
}
# Creating a subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.0.0/20"

  tags = {
    Name = "Public_Subnet"
  }
}
#Creating Internet Gateway 
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}
#Create a Route Table 
resource "aws_route_table" "Public_rt_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }


  tags = {
    Name = "Public_Route"
  }
}
resource "aws_route_table_association" "public_route_ass" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Public_rt_table.id
}
#Creating Security Group 
#resource "aws_vpc" "app_vpc" {
# cidr_block = "10.0.0.0/20"
#}

resource "aws_security_group" "Pyapp_SG" {
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3001
    to_port     = 3001
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating a Load Balancer 
resource "aws_lb" "test_app" {
  name               = "test-app-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Pyapp_SG.id]
  subnets            = [aws_subnet.public_subnet.id]

  enable_deletion_protection = false

}
# Creating a Target Group for the Load Balancer 
resource "aws_lb_target_group" "pyapp-tg" {
  name        = "tf-pyapp-lb-alb-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.app_vpc.id
}
#Creating a load balancer listener
resource "aws_lb_listener" "pyapp_listener" {
  load_balancer_arn = aws_lb.test_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pyapp-tg.arn
  }
}


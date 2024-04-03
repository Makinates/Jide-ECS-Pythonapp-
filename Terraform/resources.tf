resource "aws_ecs_cluster" "ecs_cluster" {
  name = "pyapp_cluster"


}
resource "aws_ecs_task_definition" "test_task" {
  family                   = "dev_Family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "dev_app",
    "image": "public.ecr.aws/d0z4x7p7/jide-first-repo",
    "cpu": 1024,
    "memory": 2048,
    "essential": true, 
    "portMapping": [

        {
            "containerPort": 80,
            "hostPort":80
        }
    ]

  }
  
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
# Creation of AWS IAM role for ECS 

#Creation of the ECS Service 
resource "aws_ecs_service" "pyapp_service" {
  name            = "pyapp_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.test_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.pyapp-tg.arn
    container_name   = "dev_app"
    container_port   = 8080
  }
  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.Pyapp_SG.id]
  }
  depends_on = [aws_lb_listener.pyapp_listener]

}

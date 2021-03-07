resource "aws_ecs_cluster" "main" {
  name = "sigo-cluster"
}

resource "aws_ecs_task_definition" "sigo_gn_service" {
    family = "sigo_gn_service"
    execution_role_arn = "arn:aws:iam::651358974252:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
    network_mode   = "awsvpc"
    container_definitions = file("task-definitions/sigo_gn.json")
    requires_compatibilities = ["FARGATE"]
    cpu = 1024
    memory = 2048
}


resource "aws_ecs_service" "sigo_gn_service" {
  name            = "sigo_gn-service"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.sigo_gn_service.arn}"
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks.id}"]
    subnets          = "${aws_subnet.private.*.id}"
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "sigo_gn"
    container_port   = "8080"
  }

  depends_on = [
    aws_alb_listener.front_end,
  ]
}
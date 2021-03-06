resource "aws_ecs_cluster" "main" {
  name = "sigo-cluster"
}

data "template_file" "sigo_gn_service" {
  template = "${file("task-definitions/sigo_gn.json")}"

  vars = {
   repository_url = "${aws_ecr_repository.gestao_normas.repository_url}"
  }
}

resource "aws_ecs_task_definition" "sigo_gn_service" {
    family = "sigo_gn_service"
    execution_role_arn = "arn:aws:iam::651358974252:role/ecsTasks"
    network_mode   = "awsvpc"
    container_definitions = "${data.template_file.sigo_gn_service.rendered}"
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
[
  {
    "name": "${app_name}",
    "image": "${docker_image}",
    "essential": true,
    "cpu": ${cpu},
    "memory": ${memory},
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${app_name}",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "networkMode": "awsvpc",
    "portMappings": [{
      "hostPort": ${app_port},
      "protocol": "tcp",
      "containerPort": ${app_port}
    }],
    "mountPoints": [
      {
        "sourceVolume": "${app_name}-ecs-service-volume",
        "containerPath": "/tmp",
        "readOnly": false
      }
    ], 
    "environment": [${environment}],
    "secrets": [${secrets}]    
  }
]

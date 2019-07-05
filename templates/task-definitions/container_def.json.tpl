[
  {
    "name": "${name}",
    "image": "${image}",
    "cpu": 100,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${contianer_port},
        "hostPort": ${host_port},
        "protocol": "tcp"
      }
    ]
  }
]
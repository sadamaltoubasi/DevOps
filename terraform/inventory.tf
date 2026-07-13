resource "local_file" "ansible_stage_inventory" {
  filename = "${path.module}/../ansible/stage.inventory"
  content  = <<EOT
[all:vars]

ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -i {{ ssh_key_path }} -W %h:%p -q ubuntu@${aws_instance.bastion-host.public_ip}"'

[rmqsrvgrp]
${aws_instance.rabbitmq_server.private_ip}

[mcsrvgrp]
${aws_instance.memcached_server.private_ip}

[appsrvgrp]
${aws_instance.app_server.private_ip}
EOT
}


resource "local_file" "ansible_prod_inventory" {
  filename = "${path.module}/../ansible/prod.inventory"
  content  = <<EOT
[all:vars]

ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -i {{ ssh_key_path }} -W %h:%p -q ubuntu@${aws_instance.bastion-host.public_ip}"'


[appsrvgrp]
${aws_instance.prod_server.private_ip}
EOT
}
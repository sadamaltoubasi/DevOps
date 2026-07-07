resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/prod.inventory"
  content  = <<EOT
[all:vars]

ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -i {{ ssh_key_path }} -W %h:%p -q ubuntu@${aws_instance.bastion-host.public_ip}"'

[dbsrvgrp]
${aws_instance.app_server.private_ip}

[rmqsrvgrp]
${aws_instance.rabbitmq_server.private_ip}

[mcsrvgrp]
${aws_instance.memcached_server.private_ip}

[appsrvgrp]
${aws_instance.app_server.private_ip}
EOT
}
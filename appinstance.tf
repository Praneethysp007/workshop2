resource "aws_key_pair" "key1" {
  key_name   = "key1-key"
  public_key = file(var.aws_key_pair)

}


# data "aws_subnet" "app" {
#   vpc_id = aws_vpc.itsmyvpc.id
#   filter {
#     name =   "tag:Name"
#     values = ["app*"]
#   }
#   depends_on = [aws_subnet.sub]
# }
# data "aws_subnet" "app2" {
#   filter {
#     name =   "tag:Name"
#     values = ["app*"]
#   }
#   depends_on = [aws_subnet.sub]
# }
# data "aws_subnet" "web" {
#   filter {
#     name =   "tag:Name"
#     values = [var.web]
#   }
#   depends_on = [aws_subnet.sub]
#}

resource "aws_instance" "appserver" {

  count                       = length(var.ec2tags)
  ami                         = var.awsamiid[count.index]
  associate_public_ip_address = true
  instance_type               = var.awsinstancetype[count.index]
  key_name                    = aws_key_pair.key1.key_name
  vpc_security_group_ids      = [aws_security_group.websec.id]
  subnet_id                   = aws_subnet.sub.*.id[count.index]              

  tags = {
    Name = var.ec2tags[count.index]
  }

  depends_on = [aws_vpc.itsmyvpc, aws_subnet.sub, aws_key_pair.key1, aws_subnet.sub, aws_security_group.websec]




  connection {
     type        = "ssh"
     user        = "ubuntu"
     private_key = file(var.privatekey)
     host        = self.public_ip
   }

  


   provisioner "file" {
      source      = "nopcommerce.service"
     destination = "/home/ubuntu/nopcommerce.service"
   }
   provisioner "file" {
     source      = "nopcommerce.yaml"
     destination = "/home/ubuntu/nopcommerce.yaml"
   }
    provisioner "file" {
     source      = "default"
     destination = "/home/ubuntu/default"
   }

   provisioner "remote-exec" {
     inline = [
       "sudo apt update",
       "sudo apt install software-properties-common -y",
       "sudo add-apt-repository --yes --update ppa:ansible/ansible",
       "sudo apt install ansible -y",
        "ansible-playbook -i hosts nopcommerce.yaml"
     ]
   }
}


#  data "aws_instances" "appserver" {
#   filter {
#     name   = "tag:Name"
#     values = var.ec2tags
  
#   }
# }



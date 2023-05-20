resource "aws_ebs_volume" "ebs_volume_1" {
  count             = local.n_instance
  availability_zone = aws_instance.aws_ec2[count.index].availability_zone
  size              = 10
  tags = {
    Name = "My volume #1 - POC #instance ${count.index}"
  }
}

resource "aws_ebs_volume" "ebs_volume_2" {
  count             = local.n_instance
  availability_zone = aws_instance.aws_ec2[count.index].availability_zone
  size              = 10
  tags = {
    Name = "My volume #2 - POC #instance ${count.index}"
  }
}

resource "aws_volume_attachment" "ebs_attach_1" {
  count       = local.n_instance
  device_name = local.ebs_device_name1
  instance_id = aws_instance.aws_ec2[count.index].id
  volume_id   = aws_ebs_volume.ebs_volume_1[count.index].id
  connection {
    type        = local.connections[count.index].type
    user        = local.connections[count.index].user
    private_key = file(local.connections[count.index].private_key)
    host        = aws_instance.aws_ec2[count.index].public_ip
    timeout     = "1m"
  }
  provisioner "remote-exec" {
    inline = [
      "echo '${aws_ebs_volume.ebs_volume_1[count.index].id} /mnt/data1 xfs defaults,nofail 0 2' | sudo tee -a /etc/fstab"
    ]
  }
  force_detach = true
  depends_on   = [null_resource.wait_for_ssh]
}

resource "aws_volume_attachment" "ebs_attach_2" {
  count       = local.n_instance
  device_name = local.ebs_device_name2
  instance_id = aws_instance.aws_ec2[count.index].id
  volume_id   = aws_ebs_volume.ebs_volume_2[count.index].id
  connection {
    type        = local.connections[count.index].type
    user        = local.connections[count.index].user
    private_key = file(local.connections[count.index].private_key)
    host        = aws_instance.aws_ec2[count.index].public_ip
    timeout     = "1m"
  }
  provisioner "remote-exec" {
    inline = [
      "echo '${aws_ebs_volume.ebs_volume_2[count.index].id} /mnt/data2 xfs defaults,nofail 0 2' | sudo tee -a /etc/fstab"
    ]
  }
  force_detach = true
  depends_on   = [null_resource.wait_for_ssh]
}

resource "aws_ebs_snapshot" "ebs1_snapshot" {
  count     = local.n_instance
  volume_id = aws_volume_attachment.ebs_attach_1[count.index].volume_id
  tags = {
    Name = "EBS #1 - snapshot - POC #instance ${count.index}"
  }
  description = "Snapshot of EBS #1 volume #instance ${count.index}"
  depends_on  = [aws_volume_attachment.ebs_attach_1]
}

resource "aws_ebs_snapshot" "ebs2_snapshot" {
  count     = local.n_instance
  volume_id = aws_volume_attachment.ebs_attach_2[count.index].volume_id
  tags = {
    Name = "EBS #2 - snapshot - POC #instance ${count.index}"
  }
  description = "Snapshot of EBS #2 volume #instance ${count.index}"
  depends_on  = [aws_volume_attachment.ebs_attach_2]
}

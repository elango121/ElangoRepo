provider "aws" {
	access_key = "${var.access_key}"
	secret_key = "${var.secret_key}"
	region = "${var.region}"
}

resource "aws_instance" "elangoterraform"{

	ami = "ami-03746875d916becc0"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.elangotfkey.id}"
	
	tags = {
	Name = "elangoinstance"
	}
	vpc_security_group_ids = ["${aws_security_group.elangotfsecgroup.id}"]
	
	provisioner "local-exec"{
	//when = "create"
	command = "echo ${aws_instance.elangoterraform.public_ip}>sample.txt"
}

	provisioner "chef" {
	connection {
		host = "${self.public_ip}"
		type = "ssh"
		user = "ec2-user"
	 private_key ="${file("C:\\Terraform\\Elango\\mykey.pem")}"
	}
	client_options = ["chef_license 'accept'"]
       	  run_list =	["testenv_aws_tf_chef::default"]
   recreate_client =    true
	node_name  =    "elango.com"
	server_url =	"https://api.chef.io/organizations/accentures"
	user_name  =	"elango007"
	user_key   =	"${file("C:\\Terraform\\Elango\\chef-starter\\chef-repo\\.chef\\elango007.pem")}"
 ssl_verify_mode   =	"verify_none"
}
}

output "elangopublicip"{
	value = "${aws_instance.elangoterraform.public_ip}"
}

resource "aws_security_group" "elangotfsecgroup" {
	name = "elangosecgroup"
	description = "To allow traffic"

	ingress{
	from_port ="0"
	to_port = "0"
	protocol = "-1"
	cidr_blocks=["0.0.0.0/0"]
	}

	egress{
	from_port ="0"
	to_port = "0"
	protocol = "-1"
	cidr_blocks=["0.0.0.0/0"]
	}

}
resource "aws_key_pair" "elangotfkey" {
	key_name = "elangokeypair"
	public_key = "${file("C:\\Terraform\\Elango\\mykey.pub")}"
}

resource "aws_eip" "elangotfeip" {
	tags = {
	Name ="elangoelastieip"
	}

	instance = "${aws_instance.elangoterraform.id}"
}

resource "aws_s3_bucket" "elangobucket" {

	bucket = "elangobucket" 
	acl = "private"
//	force_destroy = "true"
}

terraform {
	backend "s3" {
	bucket = "elangobucket"
	key = "terraform.tfstate"
	region = "eu-west-1"
	}
	}

//terraform init -backend-config="access_key=AKIAZTIMJ7JHPVODYVZA" -backend-config="secret_key=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"
data "http" "ip" {
  url = "https://ifconfig.co/"
}

################################################################################
# Web apps
resource "aws_security_group" "web_sg" {
  name = "web-sg"
  description = "Allow inbound web connections"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port    = 443
    to_port      = 443
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Name = "web-sg"
  }
}

################################################################################
# Postgres databases
resource "aws_security_group" "pg_sg" {
  name = "pg-sg"
  description = "inbound connections to Postgres databases"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port    = 5432
    to_port      = 5432
    protocol     = "tcp"
    security_groups = [
      "${aws_security_group.web_sg.id}"
    ]
  }

  ingress {
    from_port    = 5432
    to_port      = 5432
    protocol     = "tcp"
    cidr_blocks = [
      "${chomp(data.http.ip.body)}/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Terraform = "true"
    Name = "pg-sg"
  }
}

################################################################################
# outputs

output "security_groups" {
  value =<<END

web_security_group=${aws_security_group.web_sg.id}
pg_security_group=${aws_security_group.pg_sg.id}

END
}

output "pg_security_group_id" {
  value = "${aws_security_group.pg_sg.id}"
}

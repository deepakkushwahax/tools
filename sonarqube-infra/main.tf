resource "aws_vpc" "sonarqube_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "sonarqube-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sonarqube_vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.sonarqube_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "sonarqube-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sonarqube_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "Allow SSH and SonarQube"
  vpc_id      = aws_vpc.sonarqube_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SonarQube UI"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all egress"
  }

  tags = {
    Name = "sonarqube-sg"
  }
}

resource "aws_instance" "sonarqube" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sonarqube_sg.id]

  tags = {
    Name = "sonarqube-ec2"
  }
}

resource "aws_cloudwatch_metric_alarm" "sonarqube_status_check" {
  alarm_name          = "SonarQube-EC2-StatusCheck"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Triggers if EC2 fails status checks"

  dimensions = {
    InstanceId = aws_instance.sonarqube.id
  }
}

output "ec2_public_ip" {
  value = aws_instance.sonarqube.public_ip
}

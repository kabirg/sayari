output "vpc" {
  value = aws_vpc.main.id
}

output "subnet" {
  value = aws_subnet.public_subnet.id
}

output "igw" {
  value = aws_internet_gateway.igw.id
}

output "sg" {
  value = aws_security_group.webserver_sg.id
}

output "rt" {
  value = aws_route_table.public-rt.id
}

output "webserver" {
  value = aws_instance.webserver.id
}

output "eip" {
  value = aws_eip.eip.id
}

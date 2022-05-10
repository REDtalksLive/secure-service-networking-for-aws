## Use your public IP for external access security group

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}

output "my_ip_addr" {
  value = local.ifconfig_co_json.ip
}

//use with
#ingress {
#  from_port = 0
#  to_port = 0
#  protocol = "-1"
#  cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
#}
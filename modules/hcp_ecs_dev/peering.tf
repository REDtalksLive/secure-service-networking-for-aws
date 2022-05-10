## Peering between EKS Dev VPC and ECS Dev VPC

resource "aws_vpc_peering_connection" "ecs_dev_to_eks_dev" {
  vpc_id        = var.ecs_dev_vpc_id
  peer_owner_id = var.eks_dev_vpc_owner_id
  peer_vpc_id   = var.eks_dev_aws_vpc_id
  auto_accept   = true
}


# Routes between EKS Dev VPC and ECS Dev VPC

resource "aws_route" "eks_dev_to_ecs_dev" {
  count                     = length(var.eks_dev_route_table_ids)
  route_table_id            = var.eks_dev_route_table_ids[count.index]
  destination_cidr_block    = var.ecs_dev_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ecs_dev_to_eks_dev.id
}

resource "aws_route" "ecs_dev_to_eks_dev" {
  count                     = length(var.ecs_dev_route_table_ids)
  route_table_id            = var.ecs_dev_route_table_ids[count.index]
  destination_cidr_block    = var.eks_dev_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ecs_dev_to_eks_dev.id
}

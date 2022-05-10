// Create Admin Partition and Namespace for the client
resource "consul_admin_partition" "ecs-dev" {
  name        = "ecs-dev"
  description = "Partition for ecs service"
}

resource "consul_admin_partition" "eks-dev" {
  name        = "eks-dev"
  description = "Partition for ecs service"
}


resource "consul_config_entry" "proxy_defaults" {

  kind = "proxy-defaults"
  name = "global"

  config_json = jsonencode({
    MeshGateway = {
      Mode = "local"
    }
  })
}

resource "consul_config_entry" "exported_eks_services" {
  kind = "exported-services"
  # Note that only "global" is currently supported for proxy-defaults and that
  # Consul will override this attribute if you set it to anything else.
  name = consul_admin_partition.eks-dev.name

  config_json = jsonencode({
    Services = [
      {
        Name = "product-api"
        Partition = consul_admin_partition.eks-dev.name
        Namespace = "default"
        Consumers = [
          {
            Partition = consul_admin_partition.ecs-dev.name
          },
        ]
      },
      {
        Name = "payments"
        Partition = consul_admin_partition.eks-dev.name
        Namespace = "default"
        Consumers = [
          {
            Partition = consul_admin_partition.ecs-dev.name
          },
        ]
      }
    ]
  })
}

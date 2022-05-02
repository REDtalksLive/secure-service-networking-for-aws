# Troubleshooting Secure Service Networking on AWS

## HCP

1. Verify your HCP Service Principle ID and Secret
2. Check for HVN Peering / Route errors


### HCP Service Principle credentials

You can verify your HCP credentials by running the following Terraform code which retrieves a list of the available Consul versions. This Terraform code does not deploy or modify anything so is great for verifying authentication.

1) Navigate to the `troubleshooting/hcp_auth_test` directory
2) `export` your credentials the shell environment
3) Run `terraform apply`

```sh
export HCP_CLIENT_ID=<hcp_client_id>
export HCP_CLIENT_SECRET=<hcp_client_secret>
```


### HVN Peering / Routing errors

```sh
│ Error: unable to create HVN route (subnet-06a2b2a8d8c6fd0bd): create HVN route operation (d378e288-47b1-4b7b-bd69-da88b7207562) failed [code=13, message=terraform apply failed: error applying Terraform: Error authorizing security group ingress rules: RulesPerSecurityGroupLimitExceeded: The maximum number of rules per security group has been reached.       status code: 400, request id: 06ddf845-9ace-4900-bfc5-566922b2e076    on main.tf line 122, in resource "aws_security_group" "sg":  122: resource "aws_security_group" "sg" {]
│ 
│   with module.aws_hcp_consul.hcp_hvn_route.peering_route_prod[1],
│   on .terraform/modules/aws_hcp_consul/main.tf line 71, in resource "hcp_hvn_route" "peering_route_prod":
│   71: resource "hcp_hvn_route" "peering_route_prod" {
```

## EKS

### Cluster creation timeouts:

**Problem/Symptom:**

Default module timeout is **10m**, but EKS often takes longer than that to create a cluster:

```sh
module.hcp_eks["eks-prod"].module.eks.aws_eks_cluster.this[0]: Still creating... [10m40s elapsed]
module.hcp_eks["eks-dev"].module.eks.aws_eks_cluster.this[0]: Still creating... [10m40s elapsed]
module.hcp_eks["eks-dev"].module.eks.aws_eks_cluster.this[0]: Still creating... [10m50s elapsed]
module.hcp_eks["eks-prod"].module.eks.aws_eks_cluster.this[0]: Still creating... [10m50s elapsed]
module.hcp_eks["eks-prod"].module.eks.aws_eks_cluster.this[0]: Still creating... [11m0s elapsed]
module.hcp_eks["eks-dev"].module.eks.aws_eks_cluster.this[0]: Still creating... [11m0s elapsed]
module.hcp_eks["eks-prod"].module.eks.aws_eks_cluster.this[0]: Still creating... [11m10s elapsed]
```

**Solution:**
```sh
  cluster_timeouts         = {
    create = "15m"
  }
```


Where do I begin, k8s....

//TODO: add kubectl remote exec commands to test side-cars

**NOTE:** aws cli documentation for EKS: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/eks/index.html


## ECS

### Get your environment ready to remote execute commands within the containers

1) **Install the `aws cli` v2.**

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**NOTE:** You may need to check your path, or move the binary to a location in your path.

**NOTE:** For other operating systems please refer to the `aws cli` install documentation: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


2) **Install the aws session manager plugin.**

Ubnutu instructions below: 
```sh
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

**NOTE:** For other operating systems please refer to the `session-manager` installation documentation here: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html 


### Export your credentials

```sh
export AWS_ACCESS_KEY_ID=<your_aws_access_key_id>   # Numbers, letters...
export AWS_SECRET_ACCESS_KEY=<your_aws_secret_key>  # Numbers, letters...
export CLIENT_REGION=<client_region>                # e.g. "us-west-2"
export CLIENT_CLUSTER_ARN=<ecs_cluster_arn>         # aws web console
```

```sh
aws ecs execute-command --region ${CLIENT_REGION} --cluster ${CLIENT_CLUSTER_ARN} --task ${CLIENT_TASK_ID} --container=basic --command '/bin/sh -c "curl localhost:1234"' --interactive
```

Example command to access the _frontend_ service sidecar proxy:

```sh
export CLIENT_TASK_ID=8851afcf907c417abb46112b7e978163

/usr/local/bin/aws ecs execute-command --region ${CLIENT_REGION} --cluster ${CLIENT_CLUSTER_ARN} --task ${CLIENT_TASK_ID} --container=frontend --command '/bin/sh -c "wget -O - http://localhost:3000"' --interactive
```

Example command to access the _public_ service sidecar proxy:

```sh
export CLIENT_TASK_ID=685fab0404804ccfbdf5c86ae4aa9bc6

/usr/local/bin/aws ecs execute-command --region ${CLIENT_REGION} --cluster ${CLIENT_CLUSTER_ARN} --task ${CLIENT_TASK_ID} --container=public-api --command '/bin/sh -c "wget -O - http://localhost:8080"' --interactive
```

**NOTE:** aws cli documentation for ECS: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecs/index.html 


## EC2


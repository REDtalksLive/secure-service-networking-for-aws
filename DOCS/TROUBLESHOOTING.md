# Troubleshooting Secure Service Networking on AWS

## Table of Contents

- [Troubleshooting HCP](#Troubleshooting%20HCP)
  - [HCP Service Principle credentials](#HCP%20Service%20Principle%20credentials)
  - [HVN Peering / Routing errors](#HVN%20Peering%20/%20Routing%20errors)
- [Troubleshooting EKS](#Troubleshooting%20EKS)
  - [Cluster creation timeouts](#Cluster%20creation%20timeouts)
  - [Helm Chart install fails](#Helm%20Chart%20install%20fails)
    - [Configure your kubectl env](#Configure%20your%20kubectl%20env)
    - [Helm install troubleshooting](#Helm%20install%20troubleshooting)
    - [Troubleshooting services with EKS](#Troubleshooting%20services%20with%20EKS)
- [Troubleshooting ECS](#Troubleshooting%20ECS)
  - [Prep environment for remote exec](#Prep%20environment%20for%20remote%20exec)
  - [Export your credentials](#Export%20your%20credentials)
- [Troubleshooting EC2](#Troubleshooting%20EC2)


---
# Troubleshooting HCP

1. Verify your HCP Service Principle ID and Secret
2. Check for HVN Peering / Route errors


## HCP Service Principle credentials

You can verify your HCP credentials by running the following Terraform code which retrieves a list of the available Consul versions. This Terraform code does not deploy or modify anything so is great for verifying authentication.

1) Navigate to the `troubleshooting/hcp_auth_test` directory
2) `export` your credentials the shell environment
3) Run `terraform apply`

```sh
export HCP_CLIENT_ID=<hcp_client_id>
export HCP_CLIENT_SECRET=<hcp_client_secret>
```


## HVN Peering / Routing errors

```sh
│ Error: unable to create HVN route (subnet-06a2b2a8d8c6fd0bd): create HVN route operation (d378e288-47b1-4b7b-bd69-da88b7207562) failed [code=13, message=terraform apply failed: error applying Terraform: Error authorizing security group ingress rules: RulesPerSecurityGroupLimitExceeded: The maximum number of rules per security group has been reached.       status code: 400, request id: 06ddf845-9ace-4900-bfc5-566922b2e076    on main.tf line 122, in resource "aws_security_group" "sg":  122: resource "aws_security_group" "sg" {]
│ 
│   with module.aws_hcp_consul.hcp_hvn_route.peering_route_prod[1],
│   on .terraform/modules/aws_hcp_consul/main.tf line 71, in resource "hcp_hvn_route" "peering_route_prod":
│   71: resource "hcp_hvn_route" "peering_route_prod" {
```

---
# Troubleshooting EKS

## Cluster creation timeouts

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

## Helm Chart install fails

1. Don't use Consul Helm Chart 0.43.0 unless you ALSO want to upgrade to consul 1.12.0
2. So use Consul Helm Chart 0.42.0 with Consul 1.11.5 instead.

The terraform provider for helm, and its `helm_release` resource, provide very little usable output when things go wrong, e.g.:

```sh
module.hcp_eks_dev.module.eks_consul_client.helm_release.consul: Still creating... [5m10s elapsed]
╷
│ Warning: Helm release "consul" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
│ 
│   with module.hcp_eks_dev.module.eks_consul_client.helm_release.consul,
│   on modules/hcp_eks_dev/modules/hcp-eks-client/main.tf line 16, in resource "helm_release" "consul":
│   16: resource "helm_release" "consul" {
│ 
╵
╷
│ Error: failed pre-install: timed out waiting for the condition
│ 
│   with module.hcp_eks_dev.module.eks_consul_client.helm_release.consul,
│   on modules/hcp_eks_dev/modules/hcp-eks-client/main.tf line 16, in resource "helm_release" "consul":
│   16: resource "helm_release" "consul" {
```

Putting the helm provider aside for a moment and running the helm commmand line tool is the only way to understand what `the error` and `the condition` are. In this sectoin we'll get setup to use `helm`

If you haven't already, configure your kubectl environment. If you can successfully run `kubectl get svc` and see your ClusterIP, skip to the *helm troubleshooting*

### Configure your kubectl env

1. Install `kubectl`

`brew install kubectl`

2. Configure `kuectl`

There should be a *kubeconfig* file in the directory where you executed `terraform apply` named something like: `kubeconfig_hcp-consul-hvii1s-eks-dev`

`export KUBECONFIG=./kubeconfig_hcp-consul-hvii1s-eks-dev`

Now run `kubectl get svc`

If you see this:
```sh
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

Then something went wrong with the previous step. Check your kubeconfig file location, and that you exported its location correctly.

If you see:
```sh
kubectl get svc
Unable to connect to the server: getting credentials: exec: executable aws-iam-authenticator not found

It looks like you are trying to use a client-go credential plugin that is not installed.

To learn more about this feature, consult the documentation available at:
      https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins
```

then you need to install aws-iam-authenticator, like so:
```sh
brew install aws-iam-authenticator
```

This 'should' now work and you 'should' see something like:

```sh
kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   27m
```

### Helm install troubleshooting

1. Install `helm`

`brew install helm`

2. Configure `helm`

With `kubectl` configured (see above if not) you should be able to execute `helm list` and see something like the following:

```sh
helm list
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS  CHART           APP VERSION
consul  default         1               2022-05-05 19:05:35.39536 -0700 PDT     failed  consul-0.42.0   1.11.4
```

NOTE: the STATUS is showing `failed`

To investigate why its failing, lets run the helm install from the command line, instead of the terraform provider:

1. Create a temporarty folder: `mkdir temp`
2. Copy the template file (assuming its `hcp_eks_dev` that failed instal): `cp modules/hcp_eks_dev/modules/hcp-eks-client/templates/consul.tpl temp/consul.yaml`
3. Edit the interpolated values that would be generated by terraform, e.g. replace `${datacenter}` with the name of your consul datacenter.
NOTE: the default datacenter name is the same as the cluster-id. Access the HCP Consul cluster UI to retrieve the cluster-id/datacenter name, e.g. `hcp-consul-hvii1s`

* `${datacenter}` - HCP Consul cluster ID
* `${k8s_api_endpoint}` is in thekubeconfig file generated when you ran terraform:
e.g. `https://4B245385EB59A376D9853005C46D497D.gr7.us-west-2.eks.amazonaws.com`

Verify you have the heml repo installed:

`helm search repo hashicorp/consul`

Remove the previous failed install:

`helm uninstall consul`

Run the install from the command line in the where the kubeconfig file resides, with the `--debug` flag set, like so:
`helm install consul hashicorp/consul  -f temp/consul.yaml --debug` 

Take note of any errors you may be encountering. To the google-copter, batman!

### Troubleshooting services with EKS

//TODO: add kubectl remote exec commands to test side-cars


**NOTE:** aws cli documentation for EKS: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/eks/index.html

---
# Troubleshooting ECS

## Prep environment for remote exec

Get your environment ready to remote execute commands within the containers

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


## Export your credentials

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


---
# Troubleshooting EC2


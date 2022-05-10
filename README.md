# secure-service-networking-for-aws
Secure Service Networking for AWS w/ HashiCorp Consul

## Table of Contents

- [Build Environment](#Build%20Environment) 
- [Obtain AWS credentials](#Obtain%20AWS%20credentials) 
- [Obtain HCP credentials](#Obtain%20HCP%20credentials) 
- [Troubleshooting](#Troubleshooting)

---
# Build Environment

Executing this terraform definition will recreate the environment from the "Secure Service Networking for AWS" Instruqt workshop:
https://play.instruqt.com/hashicorp/tracks/secure-service-networking-for-aws


To run this you will need to set the following environment variables:

```sh
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
HCP_CLIENT_ID
HCP_CLIENT_SECRET
```

For example:
```sh
export HCP_CLIENT_ID=XxXx1xx47X5x4xxXxxXXXx0Xxx8xxxXX
export HCP_CLIENT_SECRET=Xxxx16xX2XXxXXxXxxx2xxxXxXXXxxxxXX0XxxXx_Xx4x09XxxXxxxxxxxxxxx9X
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXX6XXXXXX
export AWS_SECRET_ACCESS_KEY=Xx7XX9XxXXXXxxxXXx/xXXXXxx7xXXXxXXXxXXxX
```

Then:
```sh
terraform init
terraform plan
terraform apply
```

---
# Obtaine AWS credentials

In this section well cover creating/retrieving your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY values

Scroll down to Programmatic Access in the following document:

https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html

---
# Obtain HCP credentials

Obtaining your HCP_CLIENT_ID and  HCP_CLIENT_SECRET

First navigate to the *HCP Consul* tab - this will open a new window.

1. Click the 'Sign Up' button.

2. In the left panel, navigate to "Access control (IAM)"

3. Scroll down to "Service Principals"

4. Click "Create service principal".

5. Give the service principal a name, e.g. 'aws-workshop'

6. Leave the Role as 'Contributor' and click 'Save'

7. Copy the 'Client ID' and the 'Client Secret' somewhere locally as you will need them soon.

---
# Troubleshooting

Troubleshooting steps have been moved to the `./DOCS` folder:
[TROUBLESHOOTING.md](./DOCS/TROUBLESHOOTING.md)

---
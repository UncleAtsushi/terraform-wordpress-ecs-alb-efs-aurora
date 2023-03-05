# Example Terraform Code of 3 Layer architecture WordPress with Fargate, ALB, EFS, Aurora

## What is this?
This is example Terraform code that build WordPress with ECS Fargate, ALB, EFS and Aurora.
3 Layer architecture and multi AZ structure

## Requirement
Terraform v1.3.6 or more required

## List of files and directory structure
```
[/]
 | ー terraform.tfvars
 | ー provider.tf
 | ー variable.tf
 | ー network.tf 
 | ー security.tf
 | ー storage.tf
 | ー database.tf
 | ー lb.tf
 | ー container.tf
```

## How to use this
1. Download this code into any directory.

1. In `terraform.tfvars`, set database master user name and maste password.

1. In `variable.tf`, set AWS Region environment, system name, cidr, database master user and master password as you like.

1. In `container.tf`, set your AWS account number of `execution_role_arn`.(around line 54)

1. Set AWS credential by command below.

    Mac or Linux
    ```shell
    export AWS_PROFILE=xxx
    ```
    Windows(PowerShell)
    ```powershell
    $env:AWS_PROFILE="xxx"
    ```
1. Initialize terraform.
    ```
    terraform init
    ```

1. Check what will deploy.
    ```
    terraform plan
    ```

1. Deploy AWS resources.
    ```
    terraform apply
    ```
# Infrastructure

This section explains how to use and modify the infrastructure. If you haven't already then we
thoroughly recommend using a [staging environment](environments.md) to test infrastructure.

**Note**: If Brightfame launched your environment, then we strongly recommend reading the [Terraform Getting Started](https://www.terraform.io/intro/getting-started/install.html) guide before attempting to modify infrastructure.

## Modifying the Infrastructure

Simply edit the infrastructure code as intended. Terraform files have the `*.tf` file extension.

Next use the Terraform `plan` command to verify the intended changes:

```bash
$ terraform plan
```

Finally invoke Terraform again to apply your changes to the given environment:

```bash
$ terraform apply
```

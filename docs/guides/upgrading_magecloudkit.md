# Upgrading MageCloudKit

This guide is designed for customers looking to upgrade to a newer version of MageCloudKit.

We frequently release new versions to address issues and add new features. At Brightfame we recommend
you adopt the culture of upgrading as often as possible so you are familiar with the process.

If you are referencing our Terraform modules via Git then it's usually a case of searching for
references to the old version and updating them. Then you can run the Terraform `init`, `plan`
and `apply` commands to rollout the latest changes.

For customers using our legacy ZIP archives, then we recommend using `rsync` and `diff`
to compare and merge the latest changes.

**Note**: Always read the [release notes](https://github.com/brightfame/magecloudkit/releases) before upgrading. Major versions will likely introduce changes that break backwards compatibility.

## Reducing the Blast Radius

If you want to reduce the blast radius of rolling out changes then we suggest you upgrade one module at a time.

For example to upgrade the `logs` module, you would simply change `v0.2.2` to the desired version:

```hcl
module "ecs-cluster-logs" {
  source = "git::git@github.com:brightfame/magecloudkit.git//modules/monitoring/aws/logs?ref=v0.2.2"

  name              = "production-app"
  retention_in_days = 30
}
```

After changing the module version you will need to run `terraform init` again:

```bash
$ terraform init
```

Next run the Terraform `plan` command to verify the changes:

```bash
$ terraform plan
```

And finally the `apply` command to accept them:

```bash
$ terraform apply
```

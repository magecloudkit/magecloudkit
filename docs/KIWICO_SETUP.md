# KiwiCo Setup Plan

- [ ] Create Terraform S3 state bucket with versioning enabled: `kiwico-state`
- [ ] Create ECR repostories: `kiwico/magento` and `kiwico/nginx"`.


## Commands

```bash
$ aws-vault exec kiwico -- aws s3api create-bucket --bucket kiwico-state --region us-west-1 --create-bucket-configuration LocationConstraint=us-west-1
$ aws-vault exec kiwico -- aws s3api put-bucket-versioning --bucket kiwico-state --versioning-configuration Status=Enabled
```

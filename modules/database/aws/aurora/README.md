# Aurora Module

The Aurora module is used to create Amazon Aurora instance.

Amazon Aurora is a MySQL and PostgreSQL compatible relational database built
for the cloud, that combines the performance and availability of high-end
commercial databases with the simplicity and cost-effectiveness of open source databases.
For more information please refer to the AWS article: https://aws.amazon.com/rds/aurora/

## Usage

```
module "aurora" {
  source = "./modules/database/aws/aurora"

  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"

  cluster_identifier      = "rds-prod-aurora-cluster"
  database_name           = "magento2"
  master_username         = "magento2"
  master_password         = "production"
  backup_retention_period = 7
  preferred_backup_window = "01:00-02:00"

}
```

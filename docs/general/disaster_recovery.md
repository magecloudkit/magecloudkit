# Disaster Recovery

This section outlines the steps required in an emergency situation such as the loss of a production facing application.

The best advice during downtime is to not touch anything and wait for the architecture to heal itself. By default, MageCloudKit uses
Amazon RDS with the Multi-AZ feature enabled, Auto Scaling Groups for the App Servers and Amazon ECS to run our application containers.

 * In the event of a database failure, RDS will automatically fail-over to the standby database running in a separate availability zone.
 * In the event of an application server failure, the Autoscaling group will automatically launch a new instance.
 * In the event of an ECS container failure, the ECS service will automatically launch a new container.

However in certain situations additional steps may need to be taken.

## Manually Recreating a Failed App Server

Simply terminate the EC2 instance and allow the EC2 Auto Scaling Group to automatically recreate it.

## Investigating a Server manually

Common server problems include lack of free space and/or disk inodes. You can check the status of these with:

```bash
$ df
$ df -i
```

or available memory with:

```bash
$ free -m
```

The `htop` utility provides a good overview of the instance resources:

```bash
$ htop
```

**Note:** You may need to install this using `yum` or `apt-get`.

## Restoring an RDS Database Snapshot

1. Launch a new RDS database from the snapshot using the AWS console.
2. After the RDS database is available export the database using the MySQL client tools from one of the App Servers.
3. You can then import this database dump into the primary database cluster.
4. Next, drop and recreate the existing application database using the MySQL console.
5. You can then import the database dump into the primary database cluster.

An example list of commands would be:

```bash
$ mysqldump -h <RDS_HOST_IP> -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > dbbackup-$(date +%Y%m%d-%H%M%S).sql
$ mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE
DROP DATABASE magento2;
CREATE DATABASE magento2;
$ mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < dbbackup-20180101000000.sql
```

**Note:** Dropping the database will incur application downtime.

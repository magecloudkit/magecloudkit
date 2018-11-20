# Backups

## Database

The databases are automatically backed up every hour by AWS and stored securely. By default, they are kept for a period of 7 days.
This setting is configurable using the parameters provided by the `database/aws/aurora` module.

**Note:** Due to Amazon security policies it is not possible to access a database backup directly. Instead you must either
revert the RDS instance to the specific backup or launch a new RDS instance based on the backup.

## Media Assets

The media assets are stored on a durable EFS filesystem. For added security you may wish to back this data up to an S3 bucket.

## Jenkins Data

The Jenkins data is stored on a durable EFS filesystem. For added security you may wish to back this data up to an S3 bucket.

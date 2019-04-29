# Troubleshooting

## Troubleshooting Terraform

In the event of a Terraform failure, turn on the debug mode and re-run the plan step to see exactly what happens:

```bash
$ export TF_LOG=debug
$ make plan
```

## PHP-FPM Pool Busy

The logs may contain errors such as:

```
[21-Nov-2018 06:12:30] WARNING: [pool www] seems busy (you may need to increase pm.start_servers, or pm.min/max_spare_servers), spawning 8 children, there are 9 idle, and 18 total children
```

## MySQL server has gone away

The logs may contain errors such as:

MySQL server has gone away

```

[21-Nov-2018 06:28:10] WARNING: [pool www] child 24614 said into stdout: "2018-11-21T06:28:10+00:00 ERR (3): Warning: PDOStatement::execute(): MySQL server has gone away in /var/www/html/lib/Zend/Db/Statement/Pdo.php on line 228"
```

You can monitor this using the CloudWatch RDS `DatabaseConnections` metric.

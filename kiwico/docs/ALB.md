# ALB Load Balancer

There are currently two ALB load balancers deployed.

## production-app-alb

The ALB is configured with the follow rules:

### HTTPS Listener

| *priority* | *type* | *value* | *target arns* |
| ---------- | ------ | ------- | ------------- |
| `50` | `host-header` | `admin.kiwico.com` | `magecloudkit-production-admin` |
| `0`  | | | `magecloudkit-production-web` |

### HTTP Listener

| *priority* | *type* | *value* | *target arns* |
| ---------- | ------ | ------- | ------------- |
| `50` | `host-header` | `admin.kiwico.com` | `magecloudkit-production-admin` |
| `0`  | | | `magecloudkit-production-web` |

### Target Groups

* Web Target Group `magecloudkit-production-web`: This is the default target group. The health check is configured to go directly to Nginx (`/heartbeat`) instead of php-fpm. This is by design for 503 situations, so we can continuing serving a subset of customers if the php-fpm worker pool is exhausted.
* Admin Target Group `magecloudkit-production-admin`:

## production-jenkins-alb

This ALB is used to allow the Jenkins instance in the private subnets connect to the public internet.

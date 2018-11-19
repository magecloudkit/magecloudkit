# Troubleshooting

## Troubleshooting Terraform

In the event of a Terraform failure, turn on the debug mode and re-run the plan step to see exactly what happens:

```bash
$ export TF_LOG=debug
$ make plan
```

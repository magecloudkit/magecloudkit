# Security

At Brightfame we strongly recommend you take steps to ensure the security of your MageCloudKit powered store.

This checklist serves as a very handy security primer: https://www.sqreen.io/checklists/saas-cto-security-checklist.

## Ubuntu Linux Updates

Our Bastion and Jenkins modules are based on Ubuntu Linux 16.04. By default, they have automatic updates enabled
using the `security/auto-update` package for critical security fixes. However if for any reason you wish to update
an instance manually, you can simply run the following commands:

```bash
$ sudo apt-get update
$ sudo unattended-upgrades -d
```

## Magento Updates

Please refer to the following URL: https://magento.com/security.

## Wordpress Updates

Please refer to the following URL: https://wordpress.org/news/category/security/.

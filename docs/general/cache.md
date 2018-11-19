# Cache

MageCloudKit includes modules for creating both Redis & Memcached Elasticache clusters. Customers may wish to use one
explicitly or a combination of the two. For example you may wish to use Memcached for storing User sessions with the
locking functionality and Redis to store the Magento cache.

## Redis Cache

We recommend installing the [phpredis](https://github.com/phpredis/phpredis) library in your `Dockerfile` for
better performance.

## Clearing Memcache

You can use the following command from one of the App Servers:

```bash
$ echo 'flush_all' | nc memcached.us-west-1.magecloudkit.internal 11211
```

If you’re using PHP’s Memcached extension, you can set the `memcached.sess_locking` to `off` to avoid session locks.
The default value is `on`, which makes it act like the normal session handler.

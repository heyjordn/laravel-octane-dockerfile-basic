# Laravel Octane Dockerfile Basic
<a href="/LICENSE"><img alt="License" src="https://img.shields.io/github/license/exaco/laravel-octane-dockerfile"></a>


A very basic bare bones, multi-stage Dockerfile for [Laravel Octane](https://github.com/laravel/octane)
powered web services and microservices.

The Docker configuration provides the following setup:

- PHP 8.0 and 8.1 official DebianBuster-based images
- Preconfigured JIT compiler and OPcache

## PHP extensions

And the following PHP extensions are included:

- [x] OpenSwoole/Swoole with support of OpenSSL, HTTP/2, Native cURL hook for coroutines, `mysqlnd` and asynchronous DNS.
- [x] OPcache
- [x] Redis
- [x] PCNTL
- [x] BCMath
- [x] INTL
- [x] pdo_mysql
- [x] zip
- [x] cURL
- [x] GD
- [x] mbstring

## Usage

Clone this repository:
```
git clone git@github.com:heyjordn/laravel-octane-dockerfile-basic.git
```
Copy cloned directory content including `deployment` directory, `Dockerfile` and `.dockerignore` into your Octane powered Laravel project
Change directory to your Laravel project

Build your image:

```
docker build -t <image-name>:<tag> .
```
Start the container:
```
docker run -p <port>:9000 --rm <image-name>:<tag>
```

## Configuration

There are something that you maybe want to configure:

- Swoole HTTP server config in `supervisord.app.conf`
- OPcache and JIT configurations in `opcache.ini`
- PHP configurations in `php.ini`
- `ENTRYPOINT` Bash script in `entrypoint.sh`
option along with the build command

### Recommended options for `octane.php`

```php
// config/octane.php

return [
    'swoole' => [
        'options' => [
            'http_compression' => true,
            'http_compression_level' => 6, // 1 - 9
            'compression_min_length' => 20,
            'open_http2_protocol' => true
        ]
    ]
];

```
## Todo

- [ ] Reduce build time by removing extra extensions/deps.

## License

This repository is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).


## Special Thanks

Special thanks to [exaco](https://github.com/exaco) and [laravel-octane-dockerfile](https://github.com/exaco/laravel-octane-dockerfile) for the head start, this is essentially that dockerfile without horizon, scheduler and some extra extensions. Check out [laravel-octane-dockerfile](https://github.com/exaco/laravel-octane-dockerfile) to see the production ready file.
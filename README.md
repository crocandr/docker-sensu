# Sensu in docker

## Build

```
docker build -t croc/sensu .
```

## Run

### Redis

Redis from official image

```
docker run -tid --name=redis -v /srv/redis:/data redis redis-server --appendonly yes
```

More infos: https://hub.docker.com/_/redis/

### RabbitMQ

RabbitMQ from official image

```
docker run -tid --name=rabbitmq -e RABBITMQ_DEFAULT_USER=sensu -e RABBITMQ_DEFAULT_PASS=sensu rabbitmq:3-management
```

More infos: https://hub.docker.com/_/rabbitmq/

### Sensu

#### Preconfig

You can choose a configure method:

  - one big config file
  - multiple small configs file in a directory


##### Template file

If you haven't any config file, you can copy a config template from the sensu container or you can use my examples below.

First start:

```
docker create --name=sensu croc/sensu
```

Copy template config file:

```
mkdir /srv/sensu
docker cp sensu:/etc/sensu/config.json.example /srv/sensu/config.json
```

Remove the temporary container:

```
docker rm -v sensu
```

##### One big config file

Edit your config file. Example:

`/src/sensu/config.json`:

```
{
  "rabbitmq": {
    "host": "rabbitmqsrv",
    "port": 5672,
    "user": "sensu",
    "password": "sensu",
    "vhost": "/sensu"
  },
  "redis": {
    "host": "redissrv",
    "port": 6379
  },
  "api": {
    "host": "0.0.0.0",
    "bind": "0.0.0.0",
    "port": 4567
  },
  "handlers": {
    "default": {
      "type": "set",
      "handlers": [
        "stdout"
      ]
    },
    "stdout": {
      "type": "pipe",
      "command": "cat"
    }
  },
  "checks": {
    "test": {
      "command": "echo -n OK",
      "subscribers": [
        "test"
      ],
      "interval": 60
    }
  },
  "client": {
    "name": "localhost",
    "address": "127.0.0.1",
    "subscriptions": [
      "test"
    ]
  },
  "transport": {
    "name": "redis"
  }
}
```

##### Multiple config files

Edit your config files. Examples:

`/srv/sensu/api.json`:

```
{
  "api": {
    "host": "0.0.0.0",
    "bind": "0.0.0.0",
    "port": 4567
  }
}
```

`/srv/sensu/checks.json`:

```
{
  "checks": {
    "test": {
      "command": "echo -n OK",
      "subscribers": [
        "test"
      ],
      "interval": 60
    },
    "freedisk-root": {
      "command": "if [ $(df / | tail -n1 | awk '{ print $5 }' | cut -f1 -d'%') -le 5 ]; then echo 2; else echo 0; fi",
      "subscribers": [
         "test"
      ],
      "interval": 60
    }
  }
}
```

`/srv/sensu/client.json`:

```
{
  "client": {
    "name": "sensusrv",
    "address": "127.0.0.1",
    "subscriptions": [
      "test"
    ]
  }
}
```

`/srv/sensu/handlers.json`:

```
{
  "handlers": {
    "default": {
      "type": "set",
      "handlers": [
        "stdout"
      ]
    },
    "stdout": {
      "type": "pipe",
      "command": "cat"
    }
  }
}
```

`/srv/sensu/rabbitmq.json`:

```
{
  "rabbitmq": {
    "host": "rabbitmqsrv",
    "port": 5672,
    "user": "sensu",
    "password": "sensu",
    "vhost": "/sensu"
  }
}
```

`/srv/sensu/redis.json`:

```
{
  "redis": {
    "host": "redissrv",
    "port": 6379
  }
}
```

`/srv/sensu/transport.json`:

```
{
  "transport": {
    "name": "redis"
  }
}
```


#### Start container

Start sensu container with new config:

```
docker run -tid --name=sensu --link redis:redissrv --link rabbitmq:rabbitmqsrv -v /srv/sensu:/etc/sensu/conf.d croc/sensu /opt/start.sh
```


### Uchiwa

Uchiwa is a webUI for the community version of Sensu.

Docker hub: https://hub.docker.com/r/uchiwa/uchiwa/
Configuration infos: http://docs.uchiwa.io/en/latest/configuration/overview/

Create config:

```
mkdir /srv/uchiwa
```

example content of `/srv/uchiwa/config.json` file:

```
{
    "sensu": [
      {
        "name": "Site 1",
        "host": "sensusrv",
        "port": 4567
      }
    ],
    "uchiwa": {
      "host": "0.0.0.0",
      "port": 3000,
      "refresh": 5,
      "stats": 10,
      "user": "admin",
      "pass": "secret"
    }
}
```

Run Uchiwa:

```
docker run -tid --name=uchiwa --link sensu:sensusrv -p 3000:3000 -v /srv/uchiwa/config.json:/config/config.json uchiwa/uchiwa
```

You can login Uchiwa's WebUI on your IP and port 3000 with configured username and password. Example: http://192.168.56.103:3000


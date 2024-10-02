# Custom RabbitMQ Docker

This is just my feeble attempt at setting up a Dockerfile build that generates a RabbitMQ container with a custom username, service, queue, and exchange, that can be injected into the container at build time. It hashes the password to the way that version 4.0.2 likes and stores it in the management_definitions.json file. Really just a starter kit that might help someone else out.

# Prerequisites

- [Docker](https://docs.docker.com/desktop/)

# Configure

I didn't really configure much, but you can export the following variables in your terminal before running the build command below to start the RabbitMQ Service for some custom specification.

```Bash
export SERVICE_NAME=service
export SERVICE_QUEUE_NAME=service_queue
export SERVICE_EXCHANGE_NAME=service_exchange
export SERVICE_ACCOUNT_USERNAME=service_user
export SERVICE_ACCOUNT_PASSWORD=service_pass
export RABBIT_MQ_USER_USERNAME=user
export RABBIT_MQ_USER_PASSWORD=user_pass
```

# Build

```Bash
docker compose up --build
```

Successfully built with Docker version 27.2.0, build 3ab4256.
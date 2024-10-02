# MIT License

# Copyright (c) 2024 Derson Productions, LLC

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# 1. The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# 2. The name "Derson Productions" and any associated trademarks or other identifiers
# may not be used to endorse or promote products derived from this Software without
# specific prior written permission from Derson Productions, LLC.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

ARG RABBITMQ_VERSION=4.0.2

FROM rabbitmq:${RABBITMQ_VERSION}-management-alpine

# Turn on plugins
RUN rabbitmq-plugins enable --offline rabbitmq_mqtt rabbitmq_federation_management rabbitmq_stomp

EXPOSE 5672 15672

ENV DEFINITIONS_LOCATION=/etc/rabbitmq
# Copy the definitions.json file into the container
COPY management_definitions.json ${DEFINITIONS_LOCATION}/management_definitions.json

# replace the _RABBITMQ_VERSION_ with the actual version
RUN sed -i "s/_RABBITMQ_VERSION_/${RABBITMQ_VERSION}/" ${DEFINITIONS_LOCATION}/management_definitions.json

ENV SERVICE_NAME=${SERVICE_NAME:-service}
ENV SERVICE_QUEUE_NAME=${SERVICE_QUEUE_NAME:-service_queue}
ENV SERVICE_EXCHANGE_NAME=${SERVICE_EXCHANGE_NAME:-service_exchange}
# swap out the _SERVICE_ variables in the management_definitions.json file
RUN sed -i "s/_SERVICE_NAME_/${SERVICE_NAME}/" ${DEFINITIONS_LOCATION}/management_definitions.json
RUN sed -i "s/_SERVICE_QUEUE_NAME_/${SERVICE_QUEUE_NAME}/" ${DEFINITIONS_LOCATION}/management_definitions.json
RUN sed -i "s/_SERVICE_EXCHANGE_NAME_/${SERVICE_EXCHANGE_NAME}/" ${DEFINITIONS_LOCATION}/management_definitions.json

ENV SERVICE_ACCOUNT_USERNAME=${SERVICE_ACCOUNT_USERNAME:-service_user}
ENV SERVICE_ACCOUNT_PASSWORD=${SERVICE_ACCOUNT_PASSWORD:-service_pass}
ENV RABBIT_MQ_USER_USERNAME=${RABBIT_MQ_USER_USERNAME:-user}
ENV RABBIT_MQ_USER_PASSWORD=${RABBIT_MQ_USER_PASSWORD:-user_pass}

# swap out temp holders for the actual service account username
RUN sed -i "s/_RABBIT_MQ_SERVICE_USERNAME_/${SERVICE_ACCOUNT_USERNAME}/" ${DEFINITIONS_LOCATION}/management_definitions.json
RUN sed -i "s/_RABBIT_MQ_USER_USERNAME_/${RABBIT_MQ_USER_USERNAME}/" ${DEFINITIONS_LOCATION}/management_definitions.json

# swap out _RABBIT_MQ_SERVICE_PASSWORD_ for the actual service account password has in the definitions.json file
COPY hash_password_and_store_in_definitions.sh /etc/rabbitmq/hash_password_and_store_in_definitions.sh
RUN chmod +x /etc/rabbitmq/hash_password_and_store_in_definitions.sh
RUN /etc/rabbitmq/hash_password_and_store_in_definitions.sh

# copy the rabbitmq.conf file into the container
COPY rabbitmq.conf /etc/rabbitmq/rabbitmq.conf

# Add a health check to ensure RabbitMQ is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD rabbitmq-diagnostics -q ping || exit 1

# Start the RabbitMQ server
CMD ["rabbitmq-server"]
 
#!/bin/bash

# This script hashes the passwords and stores them in the definitions file
function encode_password() {
    local password=$1

    # Generate a random 4-byte salt
    local salt=$(head -c 4 /dev/urandom | xxd -p)

    # Concatenate the salt and the password
    local salted_password="${salt}$(echo -n $password | xxd -p)"

    # Hash the salted password with SHA-256
    local hash=$(echo -n $salted_password | xxd -r -p | sha256sum | head -c 64)

    # Concatenate the salt and the hash
    local salted_hash="${salt}${hash}"

    # Encode the result in base64
    local base64_encoded=$(echo -n $salted_hash | xxd -r -p | base64)

    echo $base64_encoded
}

# Call the encode_password function to hash the passwords
SERVICE_ACCOUNT_PASSWORD_HASH=$(encode_password $SERVICE_ACCOUNT_PASSWORD)
RABBIT_MQ_USER_PASSWORD_HASH=$(encode_password $RABBIT_MQ_USER_PASSWORD)

# swap out the password hashes in the definitions file
sed -i "s|_SERVICE_ACCOUNT_PASSWORD_HASH_|$SERVICE_ACCOUNT_PASSWORD_HASH|g" /etc/rabbitmq/management_definitions.json
sed -i "s|_RABBIT_MQ_USER_PASSWORD_HASH_|$RABBIT_MQ_USER_PASSWORD_HASH|g" /etc/rabbitmq/management_definitions.json
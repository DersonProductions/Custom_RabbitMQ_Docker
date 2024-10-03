#!/bin/bash
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
sed -i "s|_SERVICE_ACCOUNT_PASSWORD_HASH_|$SERVICE_ACCOUNT_PASSWORD_HASH|g" ${DEFINITIONS_LOCATION}/${DEFINITIONS_FILE}
sed -i "s|_RABBIT_MQ_USER_PASSWORD_HASH_|$RABBIT_MQ_USER_PASSWORD_HASH|g" ${DEFINITIONS_LOCATION}/${DEFINITIONS_FILE}
#!/bin/bash

# Make a GET request to localhost and store the response in a variable
id=$(docker ps --filter "name=blood-bank-management-system-nginx-1" | awk '{print $1}' | head -2 | tail -1)

response=$(docker exec ${id} curl 127.0.0.1)

# Check if the word "blood" is present in the response
if [[ $response != *"blood"* ]]; then
    echo "The word 'blood' is not found."
    exit 1
fi

echo "The word 'blood' is found."

#!/bin/bash

# Make a GET request to localhost and store the response in a variable
response=$(curl -s http://nginx:80)

# Check if the word "blood" is present in the response
echo $response
if [[ $response != *"blood"* ]]; then
    echo "The word 'blood' is not found."
    exit 1
fi

echo "The word 'blood' is found."

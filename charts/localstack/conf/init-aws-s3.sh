#!/bin/bash
set -e
echo "Initializing S3 bucket 'images'"
awslocal s3 mb s3://images
echo "S3 bucket 'images' created successfully."
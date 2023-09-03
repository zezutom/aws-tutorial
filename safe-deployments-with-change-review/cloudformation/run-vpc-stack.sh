#!/usr/bin/env bash

AWS_COMMAND=
while getopts ":cu" option
do
    case "${option}" in
        c)
          AWS_COMMAND="create-stack"
          shift;;
        u)
          AWS_COMMAND="update-stack"
          shift;;
        *)
          echo "Unknown option ${OPTARG}"
    esac
done

if [ -z "${AWS_COMMAND}" ]; then
    echo "Usage: $0 [-c || -u]"
    exit 1
fi

export AWS_PROFILE=default
aws configure set region us-east-1 --profile $AWS_PROFILE

ENVIRONMENT_NAME="DEV"
CF_VPC_TEMPLATE_URL="file://vpc-template.yaml"

# Validate the template
aws cloudformation validate-template --template-body $CF_VPC_TEMPLATE_URL

# Create VPC stack
aws cloudformation $AWS_COMMAND \
  --stack-name $ENVIRONMENT_NAME-VPC \
  --template-body $CF_VPC_TEMPLATE_URL

exit 0
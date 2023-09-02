#!/usr/bin/env bash

export AWS_PROFILE=default
aws configure set region us-east-1 --profile $AWS_PROFILE

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

ENVIRONMENT_NAME="DEV"
CF_RDS_TEMPLATE_URL="file://rds-template.yaml"

# Sensitive information should be stored in AWS Secrets Manager!
export DB_USERNAME="foo"
export DB_PASSWORD="foobarez"

# Validate templates
aws cloudformation validate-template --template-body $CF_RDS_TEMPLATE_URL

# Create RDS stack
aws cloudformation $AWS_COMMAND \
  --stack-name $ENVIRONMENT_NAME-RDS \
  --template-body $CF_RDS_TEMPLATE_URL \
  --parameters ParameterKey=Username,ParameterValue=$DB_USERNAME \
    ParameterKey=Password,ParameterValue=$DB_PASSWORD

exit 0
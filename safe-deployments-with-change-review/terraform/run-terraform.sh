#!/usr/bin/env bash

# Sensitive information should be stored in AWS Secrets Manager!
export TF_VAR_db_username="foo"
export TF_VAR_db_password="foobarez"

while getopts ":ia" option
do
    case "${option}" in
        i)
          terraform init && terraform plan
          shift;;
        a)
          terraform apply -auto-approve
          shift;;
        *)
          echo "Unknown option ${OPTARG}"
    esac
done


#!/bin/sh

cp terraform/terraform.tfvars.example terraform/terraform.tfvars
sed -i '.bak' "s/<ORG_ID>/${ORG_ID}/g" terraform/terraform.tfvars
sed -i '.bak' "s/<PROJECT_ID>/${PROJECT_ID}/g" terraform/terraform.tfvars
sed -i '.bak' "s/<PROJECT_ID>/${PROJECT_ID}/g" copy_to_c7n_repo/templates/required-labels-input.yaml

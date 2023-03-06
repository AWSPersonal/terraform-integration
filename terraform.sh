#!/bin/bash

# DETERMINE THE CURRENT WORKSPACE
WORKSPACE="$(terraform workspace show)"

if [ "$WORKSPACE" = "default" ]; then
  echo -e "ERROR: Workspace is set to default.\nPlease change the workspace to one of these options: [dev, qa, prod]"
  exit 1
fi

echo "RUNNING YOUR TERRAFORM IN WORKSPACE: $WORKSPACE"

# SET THE PATH TO THE APPROPRIATE VARIABLE FILE
VAR_FILE="${WORKSPACE}.tfvars"

# Check if the variable file exists
if [ ! -f "$VAR_FILE" ]; then
  echo "Error: .tfvars file not found: $VAR_FILE"
  exit 1
fi

if [[ $1 = "apply" || $1 = "destroy" ]]; then
  echo "${1^}ing your terraform resources..."
elif [[ $1 = "" ]]; then
  echo "Please provide the available parameters: [apply, destroy]"
  exit 1
else
  echo "Coudn't execute the command: $1"
  exit 1
fi

#RUN TERRAFORM WITH THE -VAR-FILE OPTION
terraform $1 -auto-approve -var-file="$VAR_FILE"
#!/bin/bash

cd ../terraform
terraform init
terraform destroy -auto-approve

cd ../scripts
./script.sh
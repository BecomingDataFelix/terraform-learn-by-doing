# how to use

```sh
cd terraform/envs/bootstrap
terraform init
terraform apply -auto-approve
# optionally, you can specify the bucket name here instead of in variables.tf  as
# terraform apply -var="state_bucket_name=test-app-terraform-state-bucket-20250907" -auto-approve

```

the date part at the end of the variable string is for uniqueness in compliance with s3 bucket naming conventions. Use whatever you want.

eg:

```sh
terraform plan -var="state_bucket_name=test-app-terraform-state-bucket-20250907" \
-out="state-bucket-plan"

terraform apply "state-bucket-plan"

terraform destroy -var="state_bucket_name=test-app-terraform-state-bucket-20250907"
```

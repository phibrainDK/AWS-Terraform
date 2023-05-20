# AWS-Terraform
Terraform as IAC for AWS

### Set Up

For initial set-up do the following commands 

```hcl
terraform init
terraform workspace new <workspace>
terraform apply -auto-approve
```

For clean up do

```hcl
terraform destroy -auto-approve
```

For Styling we can use

```hcl
terraform fmt
```
And for make validations, it's usefull

```hcl
terraform validate
```

It's good to take in mind we can check the whole structure via

```hcl
terraform plan
```

### Backend State

Basically we do the migrate initially, using something like...

```ssh
terraform init -migrate-state \
          -backend-config="bucket=${{ env.TF_BACKEND_BUCKET_NAME }}" \
          -backend-config="key=${{ env.TF_BACKEND_KEY_NAME }}" \
          -backend-config="region=${{ env.DEPLOY_REGION }}" \
          -backend-config="encrypt=true" \
          -backend-config="kms_key_id=${{ env.TF_BACKEND_KMS_KEY_ALIAS_NAME }}" \
          -backend-config="dynamodb_table=${{ env.TF_BACKEND_DYNAMODB_TABLE }}"
```

and then usually we use the set-up we defined before... cause sync it's already done...


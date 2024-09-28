# terraformDemoSP
# STEP 1 
Use the following command to check if the terraform is aware of your application


**terraform state list**

 If your bucket/infrastructure Appears then Proceed to Step 3

 # STEP 2 
Use the following command to import the resource 

**terraform import aws_s3_bucket.transactionappbucket myreactappdemoforsp**

  # STEP 3
  Use the following commands to clear the bucket
  
  **aws s3 rm s3://myreactappdemoforsp --recursive**

  # STEP 3
  Use the following commands to destroy the infrastructure

  **terraform init**
  
  **terraform state list**
  
  **terraform plan** 
  
  **terraform destroy**

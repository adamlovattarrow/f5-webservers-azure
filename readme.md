1. Clone this repo

2. Log into the Azure web interface and create a storage account and container. NOTE! the storage account name  is global and must be unique


3. Edit providers.tf and change the following lines

    storage_account_name = "terraformbackendarrow1"
    container_name       = "tfstate"

   So they match the storage account name and container name you chose

4. mkdir keys; cd keys; ssh-keygen (name key id-control_repo.rsa) 

5. terraform init

6. terraform apply

7. RDP to the jumphost using the credentials from the terraform output

8. Open Firefox and go to https://10.1.20.103:8443

9. Configure the F5

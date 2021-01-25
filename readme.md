1. Install the Azure CLI `https://docs.microsoft.com/en-us/cli/azure/install-azure-cli


2. Install Terraform https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_windows_amd64.zip


3. Open Powershell and run the command 'az login'


4. Log into the Azure web interface and create a storage account and container. NOTE! the storage account name  is global and must be unique


5. Edit providers.tf and change the following lines

    storage_account_name = "terraformbackendarrow1"
    container_name       = "tfstate"

   So they match the storage account name and container name you chose

6. mkdir keys; cd keys; ssh-keygen (name key id-control_repo.rsa) 

7. terraform init

8. terraform apply

9. RDP to the jumphost using the credentials from the terraform output

10. Open Firefox and go to https://10.1.20.103:8443

11. Configure the F5

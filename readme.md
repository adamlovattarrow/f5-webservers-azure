1. Clone this repo

2. Log into the Azure web interface and create a storage account and container. NOTE! the storage account name  is global and must be unique


3. Edit providers.tf and change the following lines

    storage_account_name = "terraformbackendarrow1"
    container_name       = "tfstate"

   So they match the storage account name and container name you chose

4. mkdir keys; contact Adam Lovatt for the key files and put them in the keys directory.

5. terraform init

6. terraform apply

7. RDP to the jumphost using the credentials from the terraform output

8. Open Firefox and go to http://puppetserver

9. Sign the certificate for juice01

10. ssh to juice01 from the jumphost, ssh -l adminuser -i id-control_repo.rsa juice01

11. sudo su -

12. puppet agent -t

13. Go back to Firefox and type in http://localhost:3000

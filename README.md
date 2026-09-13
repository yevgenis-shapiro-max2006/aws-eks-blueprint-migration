<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/e122bf9f-9842-4db2-9050-6246118453b8" />



## AWS | EKS Velero Data Migration
Velero is an open-source Kubernetes tool for backup, restore, disaster recovery, and cluster migration. It enables teams to back up Kubernetes resources and persistent data, store backups in object storage such as Amazon S3, and restore workloads to the same or another Kubernetes cluster.



🎯 Architecture Overview
```
✅ VPC containing , Public+Private Subnets , NAT Gateway
✅ EKS Cluster Provisioner Workflow 
✅ Minio S3 Object Storage 
✅ Velero Disaster Recovery
✅ Velero UI Interface
✅ Local Exec ( Logical Workloads )
```


🧱 Features
```
✔ Fully automated provisioning with Terraform
✔ High availability using multiple subnets in different Availability Zones
✔ Secure connectivity between Application and RDS
✔ Configurable environment variables for database credentials
✔ Easy to extend for other JSON data source
```



🚀 Deployment Options
```
terraform init
terraform validate
terraform plan -var-file="template.tfvars"
terraform apply -var-file="template.tfvars" -auto-approve
```


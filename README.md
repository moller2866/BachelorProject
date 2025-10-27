# BachelorProject
Setup project:
1. Copy ``terraform.tfvars.example`` and rename to ``terraform.tfvars`` in ``grafana_terraform`` and change values.
2. Run ``terraform init -upgrade`` in the ``grafana_terraform`` folder.
3. Run ``terraform plan`` in the ``grafana_terraform`` folder.
4. Run ``terraform apply`` in the ``grafana_terraform`` folder.

5. Copy ``terraform.tfvars.example`` and rename to ``terraform.tfvars`` in ``LTMO_Terraform`` and change values. **NOTE:** See ``Grafana provisioning`` for values of Grafana api key.
6. Run ``terraform init -upgrade`` in the ``LTMO_Terraform`` folder.
7. Run ``terraform plan`` in the ``LTMO_Terraform`` folder.
8. Run ``terraform apply`` in the ``LTMO_Terraform`` folder.

## Grafana Provisioning
1. First run the grafana_terraform project, such that a Grafana aci is running.
2. Access the Grafana ACI at http://grafana-umbraco-dev-dns.westeurope.azurecontainer.io:3000.
3. Go to Administration -> Users and access -> Service accounts.
4. Create a service account with admin access.
5. Click Add service account token -> Generate token.
6. Copy token and add to the terraform.tfvars for the LTMO project, as this is used for automatic provisioning. 

 
# Overview

This repository contains Terraform configurations for creating Azure infrastructure. The infrastructure includes a virtual "On-Prem" site, a hub vNet, two spoke vNets, VPN gateways, Network Security Groups (NSGs), a Bastion Host, a Log Analytical Workspace, and a DNS server.

![Diagram of infrastructure](/images/infrastructure.svg)

## Architecture

1.  **Virtual "On-Prem" Site**: A virtualized "On-Prem" Network. Connects to the hub vNet VPN gateways. 
	- Contains a Bastion Host for secure remote connections.

2.  **Hub vNet**:  A central vNet connected to the on-prem vNet via a VPN Gateway. 
	- Connects to two spoke vNets via virtual network peering. 
	- Uses a Virtual Machine for routing.
  
3.  **Spoke vNets**: Network endpoints for hosting production workload.

-  **Spoke1**: An isolated vNet that contains webapp servers.

-  **Spoke2**: An isolated vNet contains one VM and an SQL server.

4.  **DNS Server**: A DNS server to allow for "user-friendly hostnames for the webapp servers, SQL server, and the Virtual Machines.

5. **Network Security Groups**: To ensure only desired connections are possible. 

6.  **Logging**: Diagnostics are sent to a Log Analytics Workspace from the VPN gateways, Virtual Machines, and Network Security Groups (NSGs).


  # Configuration and Usage
  
  ## Variable file
  The [variables.tf](variables.tf) file improves the **modularity** and **reusability** of this code, allowing for configuration changes without changing the code itself.
  
### Variables set in `secret.tfvars`

This code **requires** a `secret.tfvars` file which is **not** provided for security reasons.

**Keep these values secret for security**.

You can set the variables in `secret.tfvars` as follows:
  
```hcl

subscription_id = "<your-subscription-id>"
 
tenant_id = "<your-tenant-id>"

client_id = "<your-client-id>"

client_secret = "<your-client-secret>"

azure_password = "<your-azure-password>"
 
azure_user = "<your-azure-username>"

shared_key = "<your-shared-key>"

domain_name = "<your-domain-name>"

```


### Acquiring these Values



-  `subscription_id` and `tenant_id`: Your Azure Subscription ID and Azure Active Directory (AD) Tenant ID.
	-  Find it in the [Subscriptions and  Azure AD section](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id)  of the Azure portal or via Azure CLI:
		```bash
		az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
		```
  

-  `client_id` and `client_secret`: The Application (client) ID and client secret of your Service Principal.

	-  Find it the [Azure AD section](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal#get-tenant-and-app-id-values-for-signing-in) of the Azure portal or via Azure CLI: 
		```bash
		az ad sp create-for-rbac --name ServicePrincipalName --query "{clientId:appId, clientSecret:password}"
		```
		- You will need to create a [security principal](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal) if you don't have one.

  
  

-  `shared_key`: An alphanumeric string between 1 and 128 characters, used for encryption by the vpn gateways

  
  

-  `domain_name`, `azure_user`, and `azure_password`: Self-created values, for the Virtual Machine logins and the FQDNs.



### Optional Variables  

In [variables.tf](variables.tf) there are variables with default values, such as the Region, Virtual Machine size, static IP addresses, and subnet prefixes.

Changing their default values is optional.

# Usage

After copying the repository and creating the `secret.tfvars` file, [initialize](https://developer.hashicorp.com/terraform/cli/commands/init) the working directory and install any needed [modules](https://registry.terraform.io/providers/hashicorp/azurerm/latest) with the command:
``` bash
 terraform init
 ```

You can see the Terraform plan without creating the infrastructure *(optional)*:

``` bash
 terraform plan -var-file="secret.tfvars"
 ```
 Apply the configuration to create the infrastructure:

``` bash
 terraform apply -var-file="secret.tfvars"
 ```
And then type `yes` to approve of the configuration.


## Outputs

After Terraform finishes, there are some outputs to help with usage of the dynamic hostnames and IP addresses.

For example:
```bash
offic_vm_1_hostname = "office-vm-1.gregchow.net"
spoke2_vm_hostname = "spoke2.gregchow.net"
sql_hostname = "sqlserver-quality-phoenix.gregchow.net"
sql_private_endpoint = "10.2.1.4"
webapp1_hostname = "webapp1-quality-phoenix.azurewebsites.net"
webapp1_private_endpoint = "10.1.1.4"
webapp2_hostname = "webapp2-quality-phoenix.azurewebsites.net"
webapp2_private_endpoint = "10.1.1.5"
```

This provides the FQDNs of the Virtual Machines, servers, and their IP addresses, as they can differ between deployments.

## Logging in with Bastion

Connections to the Virtual Machines is done via [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-linux). 

- In the Azure portal, choose the desired Virtual Machine, then Bastion.
- Input the username and password set in `secret.tfvars`


## Test Script
For easier testing, there are two equivalent test scripts, [get_test_script.ps1](get_test_script.ps1) and [get_test_script.sh](get_test_script.sh), written in PowerShell and Bash respectively.

These scripts output a string of bash commands to test connectivity between the Azure resources, either to be copied from the console directly or by copying the outputted `test.sh` file to the desired Virtual Machine.

- These commands automatically use Terraform's outputted hostnames and IP addresses, while omitting most of the normal output, instead displaying clear test results.

### Configurable Variables
There are a few set variables in these scripts:
- `WEBSTRING`: A string present in the working webpage output.
- `SQL_STRING`: A string present in the working SQL NetCat output.
- `TIMEOUT`: A timeout counter, in seconds, to speed up cases with failed connections

### Test Output
For example, a successful connection test output, from an authorized subnet:
![Successful Connection Output](/images/success.png)

And a non successful connection test output, from an unauthorized subnet:
![Failed Connection Output](/images/failure.png)

## Logging
[Diagnotic Monitoring](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings) is enabled for a few key resources to track metrics and diagnostic information. 

Sends logs to a central [Log Analytics Workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) as well as a storage account for long term storage.

Can show information such as connections allowed and blocked by the Network Security Groups (NSGs).

![Logs showing NSG connections](/images/NSG.png)

### KQL Commands
You can query the logs a [few different ways](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-query-overview), but I chose to use some basic [KQL](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/tutorials/learn-common-operators?pivots=azuremonitor) commands for my use case.

My main commands were:
- for all logs within 24 hours:
	- ```kql
		 all
		union *
		| where TimeGenerated > ago(24h)
		```
- for all VPN Gateway logs within 24 hours:
	- ```kql
		AzureDiagnostics
		| where ResourceProvider == "MICROSOFT.NETWORK" and ResourceType == "VIRTUALNETWORKGATEWAYS"
		| where TimeGenerated > ago(24h)
		```
- for all NSG logs within 24 hours:
	- ```kql
		AzureDiagnostics
		| where ResourceProvider == "MICROSOFT.NETWORK" and ResourceType == "NETWORKSECURITYGROUPS"
		| where TimeGenerated > ago(24h)
		```
- for all NSG Deny logs within 24 hours:
	- ```kql
		AzureDiagnostics
		| where ResourceProvider == "MICROSOFT.NETWORK" and ResourceType == "NETWORKSECURITYGROUPS"
		| where TimeGenerated > ago(24h)
		| where type_s == "block"
		```
		
# Files
The Terraform files are split up to organize the code and keep the source control cleaner.
- [providers.tf](providers.tf): Connection information for the Azure infrastructure, filled with values from [variables.tf](variables.tf) and `secret.tfvars`. 
- [variables.tf](variables.tf): Configurable variables for seamless deployment changes.
- [outputs.tf](outputs.tf): Outputs for hostnames and IP address values after deployment
- [random_pet.tf](random_pet.tf): Random two word pet string for dynamic naming.
- [office.tf](office.tf): Virtual Networks, Subnets, NSG, VMs, and VPN Gateway for the "On-Prem" Network.
- [hub_network.tf](hub_network.tf): Virtual Networks, Subnets, and VPN Gateway for the "Hub" Network.
- [hub_apps.tf](hub_apps.tf): Routing VM, Network Peering, and Routing Table Configuration for the "Hub-to-Spoke" Connections
- [logging.tf](logging.tf): Log Storage Account, Log Analytical Workspace, and enabling diagnostics for various resources.
- [spoke1.tf](spoke1.tf): Virtual Network, Subnets, NSG, and Network Peering for the "webapp" spoke network.
- [webapp.tf](webapp.tf): Webapp Configurations and Private Endpoints which connect to the spoke1 workload subnet.
- [spoke2.tf](spoke2.tf): Virtual Network, Subnets, NSG, and Network Peering for the "SQL" spoke network. 
- [SQL.tf](SQL.tf): SQL Server, SQL Database, and Private Endpoints which connect to the spoke2 workload subnet.
- [dns.tf](dns.tf): DNS Zone and DNS A Records for Webapps, the SQL Server, and Virtual Machines.
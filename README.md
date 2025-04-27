## Azure RedHat OpenShift Patch Scheduler using PowerShell & Azure DevOps
This repository enables automated patch scheduling in Azure Red Hat OpenShift (ARO) clusters using Argo CD's Managed Upgrade Operator.

### Features
- Connect to ARO as kubeadmin
- Detect and print the current OpenShift version
- Detect latest patch version available
- Accept a custom upgrade date from Azure DevOps pipeline
- Create an UpgradeConfig only if it doesn't already exist

### Repository Structure
 - scripts
   - schedule-aro-patch.ps1
 - aro-patch-scheduler-pipeline.yaml
 - README.md

### Prerequisites
- Azure DevOps Service Connection with access to your ARO cluster
- OC CLI and Azure CLI installed on the agent
- Managed Upgrade Operator must be installed in the cluster
  
### Pipeline Usage
Trigger the pipeline manually and pass a UTC date string:
```yaml
parameters:
  - name: upgradeDate
    type: string
    default: "2024-05-01T23:00:00Z"
```
### Sample Output 
- Current cluster version: 4.16.31
- Latest available patch version: 4.16.37
- Upgrade config created successfully. Patch scheduled for 2024-05-01T23:00:00Z

# PowerShell Module to assign Tags to ResourceGroups and Underlying Resources 
This module assigns tags to a specific resource group and its underlying resources or to all resource groups and underlying resources. In this module tags won't be applied to network resources due to bug in Microsoft cmdlet
### Access code from [here](set-tags.psm1)

## How to use this module
Import this custom module in PowerShell by running below mentioned command
```powershell
Import-Module set-tags.psm1
```
### CMDLET to assign tags to a specific resource group and underlying resources in a specific subscription

```powershell
Set-AzureTags -SubscriptionName XYX
```
### CMDLET to assign tags to resource group and underlying resources in a specific subscription

```powershell
Set-AzureTags -SubscriptionName XYX -ResourceGroup ABC
```


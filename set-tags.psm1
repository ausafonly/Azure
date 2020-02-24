<#
.Synopsis
   CMDLET to assign tags to ResourceGroups and Resources
.DESCRIPTION
   CMDLET to assign tags to specific ResourceGroup and its underlying Resources or to all ResourceGroups and Underlying Resources in a specific Subscription
.EXAMPLE
    By giving SubscriptionName parameter only this cmdlet assign tags to all ResourceGroups and all Resources in the Subscription
    Set-AzureRGTags -SubscriptionName Tesco
.EXAMPLE
    By giving SubscriptionName and ResourceGroup parameter this cmdlet assign tags to specifig ResourceGroup and its underlying Resources in the Subscription
    Set-AzureRGTags -SubscriptionName Tesco -ResourceGroup DHR-RTE-AMS-PRD-0004
#>
function Set-AzureRGTags {
    [CmdletBinding(ConfirmImpact = 'Medium')]
    [OutputType([string])]

    param (
        # Type name of the Subscription
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionName,
        # Type name of the ResourceGroup
        [Parameter(Mandatory = $false)]
        [string]$ResourceGroup
    )
    
    begin {
        # Variables for Keys and Value Tags
        $ownerkey = "Owner"
        $ownervalue = "Bond"
        $costcenterkey = "CostCenter"
        $costcentervalue = "12345"
        $resource_type_key = "ResourceType"
        $resource_type_virtualmachine_value = "VirtualMachine"
        $resource_type_storageaccount_value = "StorageAccount"
        $resource_type_servicebus_value = "ServiceBusNameSpace"
        $resource_type_publicIPAddress_value = "PublicIPAddress"
        $resource_type_vaults_value = "Vaults"
        $resource_type_databaseAccounts_value = "DatabaseAccounts"
        $resource_type_trafficmanagerprofile_value = "TrafficManagerProfile"
        $resource_type_loadbalancer_value = "LoadBalancer"
        $resource_type_networkinterface_value = "NetworkInterface"
        # Checking Current AzureRM Context
        $context = (Get-AzureRmContext).Subscription.Name
        If ($context -ne $SubscriptionName) {
            Set-AzureRmContext -Subscription $SubscriptionName
        }
        Else {
            Write-Host "$($SubscriptionName) already set as current context" -ForegroundColor Yellow
        }
        
    }
    # Adding Tags to specific ResourceGroup
    process {
        If ($ResourceGroup) {
            Write-Host "Looking for Resource Group $($ResourceGroup)" -ForegroundColor Yellow
            $resource_group = Get-AzureRmResourceGroup -Name $ResourceGroup
            $tags = $resource_group.Tags
            switch ($resource_group) {
                { $null -eq $tags } {
                    Write-Host "Tag is null adding empty string to the resource group $($resource_group.ResourceGroupName)" -ForegroundColor Green
                    $tags = @{ }
                }    

                { $tags.Keys -notcontains $ownerkey } {
                    Write-Host "Assigning Key $($ownerkey) and Value $($ownervalue) to resource group $($resource_group.ResourceGroupName)" -ForegroundColor Green
                    $tags.Add($ownerkey, $ownervalue)
                    Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $tags -Verbose
                }
                { $tags.Keys -notcontains $costcenterkey } {
                    Write-Host "Assigning Key $($costcenterkey)and Value $($costcentervalue) to resource group $($resource_group.ResourceGroupName)" -ForegroundColor Green
                    $tags.Add($costcenterkey, $costcentervalue)
                    Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $tags -Verbose
                }
            }
        
        }
        # Adding Tags to all ResourceGroups in Specific Subscription
        Else {
            Write-Host "Looking for all Resource Groups" -ForegroundColor Yellow
            $resource_group = Get-AzureRmResourceGroup
            foreach ($rg in $resource_group) {
                $tags = $rg.Tags
                switch ($rg) {
                    { $null -eq $tags } {
                        Write-Host "Tag is null adding empty string to the resource group $($rg.ResourceGroupName)" -ForegroundColor Green
                        $tags = @{ }
                    }    

                    { $tags.Keys -notcontains $ownerkey } {
                        Write-Host "Assigning Key $($ownerkey) and Value $($ownervalue) to resource group $($rg.ResourceGroupName)" -ForegroundColor Green
                        $tags.Add($ownerkey, $ownervalue)
                        Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $tags -Verbose
                    }
                    { $tags.Keys -notcontains $costcenterkey } {
                        Write-Host "Assigning Key $($costcenterkey)and Value $($costcentervalue) to resource group $($rg.ResourceGroupName)" -ForegroundColor Green
                        $tags.Add($costcenterkey, $costcentervalue)
                        Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $tags -Verbose
                    }
                }
            }
        }
        
    }
    # Adding Tags to all underlying resources in specific ResourceGroup
    end {
        if ($ResourceGroup) {
            Write-Host "looking for All Resources in ResourceGroup $($ResourceGroup)" -ForegroundColor Yellow
            $resources = Get-AzureRmResource -ResourceGroupName $ResourceGroup | Where-Object { ($_.ResourceType -eq "Microsoft.DocumentDB/databaseAccounts") -or ,
                ($_.ResourceType -eq "Microsoft.Storage/storageAccounts") -or ,
                ($_.ResourceType -eq "Microsoft.Compute/virtualMachines") -or ,
                ($_.ResourceType -eq "Microsoft.ServiceBus/namespaces") -or ,
                ($_.ResourceType -eq "Microsoft.KeyVault/vaults") }
            foreach ($r in $resources) {
                $tags = $r.Tags
                switch ($r) {
                    { $null -eq $tags } {
                        Write-Host "Tag is null adding empty string to the resource $($r.Name)" -ForegroundColor Green
                        $tags = @{ }
                    }
                    { $tags.Keys -notcontains $costcenterkey } {
                        Write-Host "Assigning key $($costcenterkey) and value $($costcentervalue) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($costcenterkey, $costcentervalue)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }
                    { $tags.Keys -notcontains $ownerkey } {
                        Write-Host "Assigning key $($ownerkey) and value $($ownervalue)to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($ownerkey, $ownervalue)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose   
                    }
                    { $r.ResourceType -eq "Microsoft.Compute/virtualMachines" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_virtualmachine_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_virtualmachine_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }
                    { $r.ResourceType -eq "Microsoft.Storage/storageAccounts" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_storageaccount_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_storageaccount_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose   
                    }
                    { $r.ResourceType -eq "Microsoft.ServiceBus/namespaces" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_servicebus_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_servicebus_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }
                    { $r.ResourceType -eq "Microsoft.Network/publicIPAddresses" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_publicIPAddress_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_publicIPAddress_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }

                    { $r.ResourceType -eq "Microsoft.KeyVault/vaults" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_vaults_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_vaults_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose 
                    }

                    { $r.ResourceType -eq "Microsoft.DocumentDB/databaseAccounts" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_databaseAccounts_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_databaseAccounts_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }

                    { $r.ResourceType -eq "Microsoft.Network/trafficmanagerprofiles" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_trafficmanagerprofile_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_trafficmanagerprofile_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }

                    { $r.ResourceType -eq "Microsoft.Network/loadBalancers" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_loadbalancer_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_loadbalancer_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }

                    { $r.ResourceType -eq "Microsoft.Network/networkInterfaces" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_networkinterface_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_networkinterface_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }
                }
            }
            
        }
        # Adding Tags to all resources in all ResourceGroups
        Else {
            Write-Host "looking for All Resources in Subscription $($SubscriptionName)" -ForegroundColor Yellow
            $resources = Get-AzureRmResource -ResourceGroupName $ResourceGroup | Where-Object { ($_.ResourceType -eq "Microsoft.DocumentDB/databaseAccounts") -or ,
                ($_.ResourceType -eq "Microsoft.Storage/storageAccounts") -or ,
                ($_.ResourceType -eq "Microsoft.Compute/virtualMachines") -or ,
                ($_.ResourceType -eq "Microsoft.ServiceBus/namespaces") -or ,
                ($_.ResourceType -eq "Microsoft.KeyVault/vaults") }
            foreach ($r in $resources) {
                $tags = $r.Tags
                switch ($r) {
                    { $null -eq $tags } {
                        Write-Host "Tag is null adding empty string to the resource $($r.Name)" -ForegroundColor Green
                        $tags = @{ }
                    }
                    { $tags.Keys -notcontains $costcenterkey } {
                        Write-Host "Assigning key $($costcenterkey) and value $($costcentervalue) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($costcenterkey, $costcentervalue)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }
                    { $tags.Keys -notcontains $ownerkey } {
                        Write-Host "Assigning key $($ownerkey) and value $($ownervalue)to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($ownerkey, $ownervalue)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose   
                    }
                    { $r.ResourceType -eq "Microsoft.Compute/virtualMachines" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_virtualmachine_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_virtualmachine_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }
                    { $r.ResourceType -eq "Microsoft.Storage/storageAccounts" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_storageaccount_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_storageaccount_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose   
                    }
                    { $r.ResourceType -eq "Microsoft.ServiceBus/namespaces" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_servicebus_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_servicebus_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }
                    { $r.ResourceType -eq "Microsoft.Network/publicIPAddresses" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_publicIPAddress_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_publicIPAddress_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }

                    { $r.ResourceType -eq "Microsoft.KeyVault/vaults" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_vaults_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_vaults_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose 
                    }

                    { $r.ResourceType -eq "Microsoft.DocumentDB/databaseAccounts" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_databaseAccounts_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_databaseAccounts_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }

                    { $r.ResourceType -eq "Microsoft.Network/trafficmanagerprofiles" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_trafficmanagerprofile_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_trafficmanagerprofile_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }

                    { $r.ResourceType -eq "Microsoft.Network/loadBalancers" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_loadbalancer_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_loadbalancer_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }

                    { $r.ResourceType -eq "Microsoft.Network/networkInterfaces" -and $tags.Keys -notcontains $resource_type_key } {
                        Write-Host "Assigning ResourceType key and value $($resource_type_networkinterface_value) to resource $($r.Name)" -ForegroundColor Green
                        $tags.Add($resource_type_key, $resource_type_networkinterface_value)
                        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $tags -Force -Verbose
                    }
                }
            }
        }
    }
}
    

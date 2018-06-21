function Get-AzureVMTag {
<#
   .Synopsis
   Get all Azure VMs and return status and value of supplied tag
   .Description
   Connect to Azure, and return status and value of supplied tag.  Only VMs which have the supplid tag against them
   will be returned.
   .Parameter SubscriptionName
   The subscription to use
   .Parameter TagName
   The name of the tag to look for
   .Example
   Get-AzureVMTag -SubscriptionName $SubscriptionName -TagName -$TagName
#>  
[CmdletBinding()]    
    param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]    
        [string] $SubscriptionName,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [string] $TagName
    )

    $Result = @()

    $ErrorActionPreference = 'stop'

    Select-AzureRmSubscription -SubscriptionName $SubscriptionName | Out-Null

    Get-AzureRmVM -PipelineVariable VMs |  ForEach-Object {
        Get-AzureRmVM -ResourceGroupName $VMs.ResourceGroupName -Name $VMs.Name -Status -PipelineVariable VMStatus | ForEach-Object {
            
            $TagValue = $VMs.Tags[$TagName]
            
            if (-not ([string]::IsNullOrEmpty($TagValue))) {

                Write-Verbose "Found '$($VMs.Name)' in resource group '$($VMs.ResourceGroupName)'"

                if (($VMStatus.Statuses | Where-Object {$_.Code -like 'PowerState*'} | Select-Object -ExpandProperty DisplayStatus)  -ne 'VM deallocated') {$Status = 'Started'} else {$Status = 'Stopped'}
        
                $VM = New-Object -TypeName PSObject
                $VM | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $VMs.ResourceGroupName
                $VM | Add-Member -MemberType NoteProperty -Name VMName -Value $VMs.Name
                $VM | Add-Member -MemberType NoteProperty -Name Status -Value $Status
                $VM | Add-Member -MemberType NoteProperty -Name TagValue -Value $TagValue
            
                $Result += $VM
            }           
        }
    } 
    return $Result
}
  
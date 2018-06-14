function Invoke-AzureVMAutoStopStart {
<#
   .Synopsis
   Stops / starts Azure VMs based on supplied tag and subscription name 
   .Description
   Find all VMs in a given subscription and if the VM has a tag with the name supplied then stop or start the VM according to the
   value of the tag
   .Parameter SubscriptionName
   The subscription to use
   .Parameter TagName
   The name of the tag to look for
   .Example
   Invoke-AzureVMAutoStopStart -SubscriptionName $SubscriptionName -TagName -$TagName
#>  
[cmdletbinding(SupportsShouldProcess=$True)]
    param (
       [string] $SubscriptionName,
       [string] $TagName       
    )

    $ErrorActionPreference = 'stop'
    $Jobs = @()

    Write-Verbose "Finding VMs in subscription '$SubscriptionName' with tag '$TagName'.."

    Get-AzureVMsStoppedDateTimes -SubscriptionName $SubscriptionName -TagName $TagName -PipelineVariable VM | ForEach-Object {

       # Write-Output "VM '$($VM.VMName)' should be $($VM.DesiredStatus) and is $($VM.Status)"

        if ($VM.Status -ne $VM.DesiredStatus) {
            
            # Stop if started
            if ($VM.Status -eq 'Started' -and $VM.DesiredStatus -eq 'Stopped') {
                $msg = "Stopping VM '$($VM.VMName)' in resource group '$($VM.ResourceGroupName)'  (should be stopped between $(($VM.DesiredStopStart).ToString("yyyy-MM-dd HH:mm")) and $(($VM.DesiredStopEnd).ToString("yyyy-MM-dd HH:mm")))"
                Write-Verbose $msg

                if ($pscmdlet.ShouldProcess($($msg))) {
                    $Job =  Stop-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.VMName -Force -AsJob 
                    $Jobs += @{'ResourceGroupName'=$($VM.ResourceGroupName);
                                'VM'=$($VM.VMName);
                                'Action'='Stop';
                                'Job'=$Job;
                                'Msg'=$msg}
                }
            }

            # Start if stopped
            if ($VM.Status -eq 'Stopped' -and $VM.DesiredStatus -eq 'Started') {
                $msg = "Starting VM '$($VM.VMName)' in resource group '$($VM.ResourceGroupName)'.."
                Write-Verbose $msg

                if ($pscmdlet.ShouldProcess($($msg))) {
                    $Job = Start-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.VMName -AsJob
                    $Jobs += @{'ResourceGroupName'=$($VM.ResourceGroupName);
                                'VM'=$($VM.VMName);
                                'Action'='Start';
                                'Job'=$Job;
                                'Msg'=$msg}
                }
            }
        }
        else {
            Write-Verbose "No action required on VM '$($VM.VMName)' in resource group '$($VM.ResourceGroupName)'"

        }
    }

    Write-Verbose "VMs stopped: $(($Jobs | Where-Object {$_.Action -eq 'Start'} |Measure-Object).Count)"
    Write-Verbose "VMs started: $(($Jobs | Where-Object {$_.Action -eq 'Stop'} |Measure-Object).Count)"

    Write-Output $Jobs
}

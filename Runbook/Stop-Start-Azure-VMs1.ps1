workflow Stop-Start-Azure-VMs1 {
    param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [string] $SubscriptionName,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [string] $TagName
    )

    $verbosepreference = 'silentlycontinue'

    Write-Output "The time is $((Get-Date).ToString("HH:mm:ss"))"

    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
    
        "Logging in to Azure..."
        Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }


    $VMs = InlineScript {
        Import-Module 'AzureVMAutoStopStart' -Force 
        $verbosepreference = 'continue'
        Write-Verbose "Finding VMs in subscription '$($USING:SubscriptionName)' with tag '$($USING:TagName)'.."
        Get-AzureVMsStoppedDateTimes -SubscriptionName $USING:SubscriptionName -TagName $USING:TagName
    }

    $Results = @()
    
    ForEach -Parallel ($VM in $VMs)  {

        if ($VM.Status -ne $VM.DesiredStatus) {
            
            # Stop if started
            if ($VM.Status -eq 'Started' -and $VM.DesiredStatus -eq 'Stopped') {
                $msg = "Stopping VM '$($VM.VMName)' in resource group '$($VM.ResourceGroupName)'  (should be stopped between $(($VM.DesiredStopStart).ToString("yyyy-MM-dd HH:mm")) and $(($VM.DesiredStopEnd).ToString("yyyy-MM-dd HH:mm")))"

                Write-Output $msg
                
                $Result = Stop-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.VMName -Force 
                    
                $ResultObj += New-Object -type PSObject -property @{'ResourceGroupName'=$($VM.ResourceGroupName);
                                'VM'=$($VM.VMName);
                                'TagValue'=$($VM.TagValue);
                                'Status'=$($VM.Status)
                                'DesiredStatus'=$($VM.DesiredStatus)
                                'DesiredStopStart'=$($VM.DesiredStopStart)
                                'DesiredStopEnd'=$($VM.DesiredStopEnd)
                                'Action'='Stop';
                                'Msg'=$msg}

                Write-Output $ResultObj
                
            }

            # Start if stopped
            if ($VM.Status -eq 'Stopped' -and $VM.DesiredStatus -eq 'Started') {
                $msg = "Starting VM '$($VM.VMName)' in resource group '$($VM.ResourceGroupName)'.."
                Write-Output $msg

                $Result = Start-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.VMName 

                $ResultObj = New-Object -type PSObject -property @{'ResourceGroupName'=$($VM.ResourceGroupName);
                            'VM'=$($VM.VMName);
                            'TagValue'=$($VM.TagValue);
                            'Status'=$($VM.Status)
                            'DesiredStatus'=$($VM.DesiredStatus)
                            'Action'='Start';
                            'Msg'=$msg}

                Write-Output $ResultObj

            }
        }
        else {
            
            $msg = "No action required on VM '$($VM.VMName)' in resource group '$($VM.ResourceGroupName)' (Desired status: $($VM.DesiredStatus), Actual status: $($VM.DesiredStatus))."
            Write-Output $msg

            $ResultObj = New-Object -type PSObject -property @{'ResourceGroupName'=$($VM.ResourceGroupName);
                        'VM'=$($VM.VMName);
                        'TagValue'=$($VM.TagValue);
                        'Status'=$($VM.Status)
                        'DesiredStatus'=$($VM.DesiredStatus)
                        'Action'='None';
                        'Msg'=$msg}

            Write-Output $ResultObj

        }
    }
}
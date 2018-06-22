function Get-AzureVMsStoppedDateTimes {
<#
   .Synopsis
   Shows status of VMs with the supplied tag name and whether or not they should be stopped.
   .Description
   Using the supplied base date and tag value supplied, generate one or more periods where the VM should be stopped
   for the next 7 days.  For this tag work the tag should be in a specific format: HH:mm-HH:mm|ddd[/ddd]. For example,
   a tag for the machine to be off on Monday to Thursday between 10:30 and 07:00 would be 10:30-07:00|Mon/Tue/Wed/Thu and 
   a tag to turn the machine off all day Sunday would be 00:00|Sun.  Multiple periods can be supplied, separated by a comma:
   10:30-07:00|Mon/Tue/Wed/Thu,00:00|Sun
   .Parameter BaseDate
   The base date from which the "Stopped" periods should be generated
   .Parameter Tag
   The value of the tag
   .Example
   Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag -$Tag
#>  
    [CmdletBinding()]
     param (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [string]  
            $SubscriptionName,
            [datetime] 
            $Date = (Get-DateInTimeZone),
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [string] 
            $TagName
            )
    
        $Result = @()

        Select-AzureRmSubscription -SubscriptionName $SubscriptionName 	-ErrorAction Stop | Out-Null
    
        Get-AzureVMTag  -SubscriptionName $SubscriptionName -TagName $TagName | 
            Select-Object -PipelineVariable VMStoppedTimeTag | ForEach-Object {
    
                $DesiredStatus = 'Started'
                $StoppedDateTimeStart = $null
                $StoppedDateTimeEnd = $null
    
                Get-AzureVMStoppedDateTimesFromTag -BaseDate $Date -Tag $VMStoppedTimeTag.TagValue -PipelineVariable VMStoppedTimes | 
                    ForEach-Object {
                            if ($VMStoppedTimes.StoppedDateTimeStart -le $Date -and $VMStoppedTimes.StoppedDateTimeEnd -ge $Date) {
                                $DesiredStatus = 'Stopped'
                                $StoppedDateTimeStart = $VMStoppedTimes.StoppedDateTimeStart
                                $StoppedDateTimeEnd = $VMStoppedTimes.StoppedDateTimeEnd
                            }                  
                }
    
                $VMStatus = New-Object -TypeName PSObject
                $VMStatus | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $VMStoppedTimeTag.ResourceGroupName
                $VMStatus | Add-Member -MemberType NoteProperty -Name VMName -Value $VMStoppedTimeTag.VMName
                $VMStatus | Add-Member -MemberType NoteProperty -Name TagValue -Value $VMStoppedTimeTag.TagValue
                $VMStatus | Add-Member -MemberType NoteProperty -Name Status -Value $VMStoppedTimeTag.Status            
                $VMStatus | Add-Member -MemberType NoteProperty -Name DesiredStatus -Value $DesiredStatus
                $VMStatus | Add-Member -MemberType NoteProperty -Name DesiredStopStart -Value $StoppedDateTimeStart
                $VMStatus | Add-Member -MemberType NoteProperty -Name DesiredStopEnd -Value $StoppedDateTimeEnd
                            
                $Result += $VMStatus                     
               
        }
    
        return $Result
    }
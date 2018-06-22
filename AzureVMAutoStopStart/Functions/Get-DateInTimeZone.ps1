function Get-DateInTimeZone {
<#
    .Synopsis
    Return the current date and time in the timezone supplied. 
    .Description
    Return the current date and time in the timezone supplied. 
    .Parameter ConvertToTimeZoneID
    The  time zone ID to convert to
    .Example
    Get-DateInTimeZone -ConvertToTimeZoneID 'GMT Standard Time'
#>  
[CmdletBinding()]    
param (
        [string] $ConvertToTimeZoneID = 'GMT Standard Time',
        [datetime] $UTCDateTime) 

    if ($null -eq $UTCDateTime) {
        $UTCDateTime = (Get-Date).ToUniversalTime() 
    }

    $ConvertToTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($ConvertToTimeZoneID)
    $ConvertedTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCDateTime, $ConvertToTimeZone)

    return $ConvertedTime

}
  
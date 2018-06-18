function Get-AzureVMStoppedDateTimesFromTag {
<#
   .Synopsis
   Takes a tag value and generates periods where the VM should be stopped for the next 7 days.
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
   GGet-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag -$Tag
#>  
[CmdletBinding()] 
param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [datetime] $BaseDate,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [string] 
        $Tag
        )

    $Result = @()    

    Write-Debug "Generating periods where VM should be stopped in the next 7 days.."
    Write-Debug "Base Date = '$($BaseDate.ToString("yyyy-MM-dd"))',  Tag value = $Tag"

    $Regx = 'Mon|Tue|Wed|Thu|Fri|Sat|Sun|/'

    ($Tag -split ',') | Select-Object -PipelineVariable StoppedTime | ForEach-Object {   

        $StoppedDateDaysString = ($StoppedTime -split '\|')[1]
        $StoppedDateDays = $StoppedDateDaysString -split '/'   

        if ( ($StoppedDateDaysString -replace $Regx,'').Length -gt 0){
            Throw "Tag days not in correct format (HH:mm-HH:mm|ddd[/ddd]). Days can only be one or more of 'Mon' 'Tue' 'Wed' 'Thu' 'Fri' 'Sat' 'Sun'. Tag was '$Tag'"
        }

        try {
            $StoppedTimeStartHour   = [int] ((($StoppedTime -split '\|')[0] -split '-')[0] -split ':')[0]
            $StoppedTimeStartMinute = [int] ((($StoppedTime -split '\|')[0] -split '-')[0] -split ':')[1]
            $StoppedTimeEndHour     = [int] ((($StoppedTime -split '\|')[0] -split '-')[1] -split ':')[0]
            $StoppedTimeEndMinute   = [int] ((($StoppedTime -split '\|')[0] -split '-')[1] -split ':')[1]

            if (($StoppedTimeStartHour -lt 0 -or $StoppedTimeEndHour -gt 23) -or ($StoppedTimeEndHour -lt 0 -or $StoppedTimeEndHour -gt 23)  )  {
                throw 
            }

            if (($StoppedTimeStartMinute -lt 0 -or $StoppedTimeStartMinute -gt 59) -or ($StoppedTimeEndMinute -lt 0 -or $StoppedTimeEndMinute -gt 59)  )  {
                throw 
            }
        }
        catch {
            throw "Tag times not in correct format (HH:mm-HH:mm|ddd[/ddd]). Tag was '$Tag'"
        }
        
        
        for ($i=0; $i -le 7; $i++) {

            $LoopDate = ($BaseDate.Date).AddDays($i)
            $LoopDateDay = (($LoopDate).DayOfWeek).ToString().Substring(0,3)
    
            if ($StoppedDateDays -contains $LoopDateDay) {

                $StoppedDateTimeStart = $LoopDate.AddHours($StoppedTimeStartHour).AddMinutes($StoppedTimeStartMinute)
                $StoppedDateTimeEnd   = $LoopDate.AddHours($StoppedTimeEndHour).AddMinutes($StoppedTimeEndMinute)

                if ($StoppedDateTimeEnd -le $StoppedDateTimeStart) {
                    $StoppedDateTimeEnd = $StoppedDateTimeEnd.AddDays(1)
                }

                if ($StoppedDateTimeEnd -ge $BaseDate) {
                    $StoppedDateTime = New-Object -TypeName PSObject
                    $StoppedDateTime | Add-Member -MemberType NoteProperty -Name StoppedDateTimeStart -Value $StoppedDateTimeStart
                    $StoppedDateTime | Add-Member -MemberType NoteProperty -Name StoppedDateTimeEnd -Value $StoppedDateTimeEnd

                    $Result += $StoppedDateTime
                }            
            }

        }
    }
    return $Result
}
$there = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace '\\Tests', '\Functions'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$file = Get-ChildItem "$there\$sut"
. $file

Describe $file.BaseName {
    
    
    Context "Test When in BST" {

        $TestDateTime = [datetime] "2018-06-21 23:30"
        $ExpectedDateTime = [datetime] "2018-06-22 00:30"

        $Result = Get-DateInTimeZone -ConvertToTimeZoneID 'GMT Standard Time' -UTCDateTime $TestDateTime

        It "Should return correct date and time" {
            $Result | Should Be ([datetime] $ExpectedDateTime)
        }

    }

    Context "Test When in GMT" {

        $TestDateTime = [datetime] "2018-01-21 23:30"
        $ExpectedDateTime = [datetime] "2018-01-21 23:30"

        $Result = Get-DateInTimeZone -ConvertToTimeZoneID 'GMT Standard Time' -UTCDateTime $TestDateTime

        It "Should return correct date and time" {
            $Result | Should Be ([datetime] $ExpectedDateTime)
        }

    }    


}
 
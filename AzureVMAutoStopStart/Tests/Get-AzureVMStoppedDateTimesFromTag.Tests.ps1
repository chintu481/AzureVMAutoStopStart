#Requires -Modules Pester
#$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$there = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace '\\Tests', '\Functions'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$file = Get-ChildItem "$there\$sut"
. $file

Describe $file.BaseName -Tags Unit {
    Context Test-BadFormats {
        
        It "throws an error if day in incorrect format" {
            try {
                $BaseDate = (Get-Date)
                $Tag = '10:59-07:00|Moon/Tue/Wed/Thu,00:00|Sun'
                Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag $Tag
            }
            catch {
                $ErrorMsg = $_.Exception.Message
            }

            $ErrorMsg | Should BeLike 'Tag days not in correct format*'
        }

        It "throws an error if time in incorrect format(1)" {
            try {
                $BaseDate = (Get-Date)
                $Tag = '10:90-07:00|Mon//Tue/Wed/Thu,00:00|Sun'
                Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag $Tag
            }
            catch {
                $ErrorMsg = $_.Exception.Message
            }

            $ErrorMsg | Should BeLike 'Tag times not in correct format*'
        }

        It "throws an error if time in incorrect format(2)" {
            try {
                $BaseDate = (Get-Date)
                $Tag = '10:0 0-07:00|Mon//Tue/Wed/Thu,00:00|Sun'
                Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag $Tag
            }
            catch {
                $ErrorMsg = $_.Exception.Message
            }

            $ErrorMsg | Should BeLike 'Tag times not in correct format*'
        }

    }

    Context Test-GoodFormats {
        It "returns 2 results when a weekend is configured" {
            $BaseDate = (Get-Date)
            $Tag = '00:00-00:00|Sat/Sun'
            
            $TestResult = Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag $Tag

            $TestResult.Count | Should Be 2
        }

        It "returns 8 results when a week is configured" {
            $BaseDate = (Get-Date "2018-06-18 10:00")
            $Tag = '23:00-23:30|Mon/Tue/Wed/Thu/Fri/Sat/Sun'
            
            $TestResult = Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag $Tag

            $TestResult.Count | Should Be 8
        }
        
        It "returns correct start and stop times" {
            $BaseDate = (Get-Date "2018-06-12 12:20")
            $Tag = '12:10-13:50|Tue'
            
            $TestResult = Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag $Tag
            $TestResult
            $TestResult[0].StoppedDateTimeStart | Should Be ([datetime] '2018-06-12 12:10:00')
            $TestResult[0].StoppedDateTimeEnd | Should Be ([datetime] '2018-06-12 13:50:00')
        }        

        It "returns correct end dates when time crosses a day boundary" {
            $BaseDate = (Get-Date "2018-06-07 18:14")
            $Tag = '23:00-01:30|Thu'
            
            $TestResult = Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag $Tag
            $TestResult
            $TestResult[0].StoppedDateTimeStart | Should Be ([datetime] '2018-06-07 23:00:00')
            $TestResult[0].StoppedDateTimeEnd | Should Be ([datetime] '2018-06-08 01:30:00')
        }

        It "returns correct end dates when time crosses a day boundary 2" {
            $BaseDate = (Get-Date "2018-06-22 00:05")
            $Tag = '17:00-07:30|Mon/Tue/Wed/Thu/Fri'
            
            $TestResult = Get-AzureVMStoppedDateTimesFromTag -BaseDate $BaseDate -Tag $Tag
            $TestResult
            $TestResult[0].StoppedDateTimeStart | Should Be ([datetime] '2018-06-21 17:00:00')
            $TestResult[0].StoppedDateTimeEnd | Should Be ([datetime] '2018-06-22 07:30:00')
        }



    }

}
$there = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace '\\Tests', '\Functions'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$file = Get-ChildItem "$there\$sut"
. $file

Describe $file.BaseName -Tags Unit {
    Context Test-AzureConnection {

        Logout-AzureRmAccount -ErrorAction SilentlyContinue | Out-Null

        try {
            $SubscriptionName = 'Visual Studio Enterprise – MPN'
            $TagName = 'StoppedBetween'
            Get-AzureVMTag -SubscriptionName $SubscriptionName -TagName $TagName -ErrorAction Stop
        }
        catch {
            $ErrorMsg = $_.Exception.Message
        }
        
        It "throws an error if not logged in to azure" {
            $ErrorMsg | Should Be 'Run Connect-AzureRmAccount to login.'
        }

    }


    Context "Test Return Object" {

    <# TODO - WORK OUT HOW TO SUCCESSFULLY MOCK AzureRM cmdlets #>
        #Mock Select-AzureRmSubscription {} 
        #Get-AzureVMTag -SubscriptionName 'Foo' -TagName 'Bar'
    }
}

$there = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace '\\Tests', '\Functions'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$file = Get-ChildItem "$there\$sut"
. $file

Describe $file.BaseName -Tags Unit {
    Context "Test Returned Object" {


        

    }
}
# ToDo:
## Needs to be added to Nutanix.Guest.Tools module if not already added.

$Credential = Get-Credential

$Computers = @(
    "computer 1",
    "computer 2"
)

Foreach ($computer in $Computers) {
    $computer_name = Invoke-Command -Credential $Credential -ScriptBlock { $env:COMPUTERNAME } -ComputerName $computer
    Write-Host "Trying to restart Nutanix Agent on $computer_name" -ForegroundColor Green
    Invoke-Command -Credential $Credential -ScriptBlock { Restart-Service -Name "Nutanix Guest Tools Agent" } -ComputerName $computer
}
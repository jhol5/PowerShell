$ConfigShare = $env:UEMConfigShare
$ProfileArchives = ($env:UEMProfileArchives.Replace(('\' + $env:USERNAME + '\archives'), ''))
$Scripts = $env:UEMScripts

function Get-UEMPathVariables {
    $obj = New-Object -TypeName psobject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name ConfigShare -Value $ConfigShare
    Add-Member -InputObject $obj -MemberType NoteProperty -Name ProfileArchivesBase -Value $ProfileArchives
    Add-Member -InputObject $obj -MemberType NoteProperty -Name Scripts -Value $Scripts

    $obj
}

Export-ModuleMember -Function Get-UEMPathVariables
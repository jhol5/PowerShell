$groups = Import-Csv 'C:\export.csv'
$s = New-CMSchedule -RecurCount 0 -RecurInterval 0 -Start "11/27/2018 9:10:00 AM"
$s.DaySpan = 7
$BaseQuery = 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.IPAddresses like '
$baseName = 'VLAN '


foreach ($group in $groups) {
    $name = $group.Description
    $query = $BaseQuery + '"%' + ($group.ScopeId.Substring(0, $group.ScopeId.Length - 1)) + '%"'
    
    $dc = New-CMDeviceCollection -Name $name -LimitingCollectionName 'Workstations' -RefreshSchedule $s -RefreshType Both

    Write-Host ($name + ' has been created.')

    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $name -RuleName ('Query for ' + $name) -QueryExpression $query


    Move-CMObject -FolderPath '001:\DeviceCollection\Windows Workstations' -InputObject $dc

    Write-Host ($name + ' has been moved.')

}
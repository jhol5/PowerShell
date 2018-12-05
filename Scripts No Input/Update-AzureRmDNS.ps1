$Records = Import-Csv C:\tjc.edu.csv
$ZoneName = 'tjc.edu'
$ResourceGroupName = 'dns'

foreach ($record in $Records) {
    if ( $record.Type -eq "Host (A)") {
        $type = 'A'
        New-AzureRmDnsRecordSet -Name $record.Name -RecordType $type -ZoneName $ZoneName `
        -ResourceGroupName 'dns' -Ttl 3600 -DnsRecords (New-AzureRmDnsRecordConfig -Ipv4Address $record.Data)
     } elseif ( $record.Type -eq "Alias (CNAME)") {
        $type = 'CNAME'
        New-AzureRmDnsRecordSet -Name $record.Name -RecordType $type -ZoneName $ZoneName `
        -ResourceGroupName $ResourceGroupName -Ttl 3600 -DnsRecords (New-AzureRmDnsRecordConfig -Cname $record.Data)
     } 
}
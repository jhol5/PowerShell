$ErrorActionPreference = "Stop"

try {
    Send-MailMessage -SmtpServer '' -to '' -from '' -Subject 'VDI Unmap Started'

    Import-Module VMware.VimAutomation.Core
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -WebOperationTimeoutSeconds -1 -Scope Session -Confirm:$false | Out-Null
    
    $c = Get-VICredentialStoreItem -File V:\Scripts\vdivcenter.xml
    Connect-VIServer -Server $c.Host -User $c.User -Password $c.Password | Out-Null
    
    $datastores = Get-Datastore | Where-Object {$_.Name -Like "*VDI*"}
    
    $esxcli = Get-EsxCli -Server $global:DefaultVIServer -WarningAction Ignore
    
    ForEach ($datastore in $datastores) {
        Write-Host -ForegroundColor Yellow ("Datastore unmap for " + $datastore.Name + " has started at " + (Get-Date))
        
        $esxcli.storage.vmfs.unmap.Invoke(300,$datastore.Name,$null) | Out-Null
        
        Write-Host -ForegroundColor Yellow ("Datastore unmap for " + $datastore.Name + " has ended at " + (Get-Date))
        Write-Host 
    }
    
    Send-MailMessage -SmtpServer '' -to '' -from '' -Subject 'VDI Unmap Finished'
} catch {
    Send-MailMessage -SmtpServer '' -to '' -from '' -Subject 'VDI Unmap Failed'
} Finally {
    Disconnect-VIServer -Confirm:$false
}
function Get-HVProblemMachines {
<#
	.SYNOPSIS
	Returns the problem VM's in the View Environment.

	.DESCRIPTION
	This function is to get the problem VM's in the View Environment and returns them in an array.
	The original script is at the end of this page, above the summary: https://blogs.vmware.com/euc/2017/01/vmware-horizon-7-powercli-6-5.html. I have removed the reboot and need to connect to vCenter and changed how the script authenticates to the View Admin server.

	.EXAMPLE
		Add-HVDesktop -PoolName 'ManualPool' -Machines 'manualPool1', 'manualPool2' -Confirm:$false
		Add managed manual VMs to existing manual pool

	.NOTES
		Original Author             : Praveen Mathamsetty.
		Original Author email       : pmathamsetty@vmware.com
		Modified/Updated By			: Joshua Holcomb
		Modified/Updated email		: Joshua Holcomb
		Version                     : 1
		Dependencies                : Make sure to have loaded VMware.HvHelper module loaded on your machine, see: https://blogs.vmware.com/euc/2017/01/vmware-horizon-7-powercli-6-5.html. Also it's state later in the script but you need to run "New-VICredentialStoreItem -host <vcenter server IP address> -user <username> -password <password> -file C:\Scripts\credfilevcenter.xml" to generate a secure encryped credental file first.

		===Tested Against Environment====
		Horizon View Server Version : 7.4.0
		PowerCLI Version            : PowerCLI 6.5, PowerCLI 6.5.1
		PowerShell Version          : 5.0

#>
	# --- Import the PowerCLI Modules required ---
    Import-Module VMware.VimAutomation.HorizonView
    Import-Module VMware.VimAutomation.Core
    Import-Module VMware.Hv.Helper

###################################################################
#                    Variables                                    #
###################################################################

    #Import Credentail Files New-VICredentialStoreItem -host <vcenter server IP address> -user <username> -password <password> -file C:\Scripts\credfilevcenter.xml
    $vcUser = Get-VICredentialStoreItem -file "C:\Scripts\view.xml"

    #Horizon Connection Server
    $cs = 'view.mydomain.com'

    $baseStates = @(
        'PROVISIONING_ERROR',
        'ERROR',
        'AGENT_UNREACHABLE',
        'AGENT_ERR_STARTUP_IN_PROGRESS',
        'AGENT_ERR_DISABLED',
        'AGENT_ERR_INVALID_IP',
        'AGENT_ERR_NEED_REBOOT',
        'AGENT_ERR_PROTOCOL_FAILURE',
        'AGENT_ERR_DOMAIN_FAILURE',
        'AGENT_CONFIG_ERROR',
        'UNKNOWN'
    )

###################################################################
#                    Initialize                                   #
###################################################################
    # --- Connect to Horizon Connection Server API Service ---
    $hvServer1 = Connect-HVServer -Server $cs -User $csUser.User -Password $csUser.Password

    # --- Get Services for interacting with the View API Service ---
    $Services1 = $hvServer1.ExtensionData

###################################################################
#                    Main                                         #
###################################################################
    if ($Services1) {
        foreach ($baseState in $baseStates) {
            # --- Get a list of VMs in this state ---
            $ProblemVMs = Get-HVMachineSummary -State $baseState -SuppressInfo $true
            
            foreach ($ProblemVM in $ProblemVMs) {
                $ProblemVM
            }
        }
        
        # --- Disconnect from View Admin ---
        Disconnect-HVServer -Server $cs -Confirm:$false | Out-Null
    } else {
        Write-Output "", "Failed to login in to Connection Server."
    }
#endregion main
}
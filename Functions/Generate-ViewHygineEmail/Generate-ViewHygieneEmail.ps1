function Generate-ViewHygieneEmail {

<#
	.SYNOPSIS
	Generates a Email report of the problem VM's in the View Environment.

	.DESCRIPTION
	The Add-HVDesktop adds virtual machines to already exiting pools by using view API service object(hvServer) of Connect-HVServer cmdlet. VMs can be added to any of unmanaged manual, managed manual or Specified name. This advanced function do basic checks for pool and view API service connection existance, hvServer object is bound to specific connection server.

	.EXAMPLE
		Generate-ViewHygieneEmail
		Sends an email to the recipients specified in the script.

	.NOTES
		Author                      : Joshua Holcomb.
		Author email                : joshua.holcomb@tjc.edu
		Version                     : 1
		Dependencies                : Make sure you update the location of the Get-HVProblemMachines script, and update the other variables to fit your environment.

		===Tested Against Environment====
		Horizon View Server Version : 7.4.0
		PowerCLI Version            : PowerCLI 6.5
		PowerShell Version          : 5.0
#>

##################################################################
#            Variables                                           #
##################################################################
    $SMTPServer = 'smtp.mydomain.com'
    $FromEmail = 'View Admin Server <viewadmin@mydomain.com>'
    $To = 'admin@mydomain.com'
    $CC = ''
    $BCC = ''
    $Subject = 'View Admin Hygiene Report'
	
    $ProblemVMs = Get-HVProblemMachines
# End Variables

##################################################################
#            Main                                                #
##################################################################
    $Body = '<p>Number of problem VMs: ' + ($ProblemVMs.Count - 1).ToString() + '</p>'
    $Body = $Body + '<table border="1" style="border-collapse: collapse;"><tr><th style="padding-left:20px; padding-right:20px;">VM Name</th><th style="padding-left:20px; padding-right:20px;">VM State</th></tr>'
    
    foreach ($ProblemVM in $ProblemVMs) {
        if ($ProblemVM.Base.Name -ne $null ) {
            $Body = $Body + '<tr>'
            $Body = $Body + '<td style="padding-left:20px; padding-right:20px;">' + $ProblemVM.Base.Name + '</td>'
            $Body = $Body + '<td style="padding-left:20px; padding-right:20px;">' + $ProblemVM.Base.BasicState + '</td>'
            $Body = $Body + '</tr>'
        }
    }

    $Body = $Body + '</table>'

    Send-MailMessage -SmtpServer $SMTPServer -From $FromEmail -To $To -Subject $Subject -BodyAsHtml $Body

# End Main
}
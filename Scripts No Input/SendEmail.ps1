################################################################################
# Send E-mail from eml file in PowerShell
# Tested on PowerShell 2.0
#
# Usage:
# 1. Configure the variables defined in Main()
#    $server = "localhost"
#    $port = "25"
#    $mailfrom = "from@example.com"
#    $rcptto = "to@example.com"
#    $filename = "test.eml"
#
# 2. Run the script in PowerShell
#
# See http://www.leeholmes.com/blog/2009/10/28/scripting-network-tcp-connections-in-powershell/
################################################################################

$encoding = New-Object System.Text.AsciiEncoding

Function SendCommand($stream, $writer, $command) {
  # Send command
	foreach ($line in $command) {
		$writer.WriteLine($line)
	}
	$writer.Flush()
	Start-Sleep -m 100

	# Get response
	$buff = New-Object System.Byte[] 4096
	$output = ""
	while ($True) {
		$size = $stream.Read($buff, 0, $buff.Length)
		if ($size -gt 0) {
			$output += $encoding.GetString($buff, 0, $size)
		}
		if (($size -lt $buff.Length) -or ($size -le 0)) {
			break
		}
	}

	if ([int]::Parse($output[0]) -gt 3) {
		throw $output
	}
	$output
}

Function SendMessage($server, $port, $mailfrom, $rcptto, $filename) {
	try {
		$socket = New-Object System.Net.Sockets.TcpClient($server, $port)
		$stream = $socket.GetStream()
		$stream.ReadTimeout = 1000
		$writer = New-Object System.IO.StreamWriter $stream

		$endOfMessage = "`r`n."

		SendCommand $stream $writer ("EHLO " + $server)
		SendCommand $stream $writer ("MAIL FROM: <" + $mailfrom + ">")
		SendCommand $stream $writer ("RCPT TO: <" + $rcptto + ">")
		SendCommand $stream $writer "DATA"
		$content = (Get-Content $filename) -join "`r`n"
		SendCommand $stream $writer ($content + $endOfMessage)
		SendCommand $stream $writer "QUIT"
	}
	catch [Exception] {
		Write-Host $Error[0]
	}
	finally {
		if ($writer -ne $Null) {
			$writer.Close()
		}
		if ($socket -ne $Null) {
			$socket.Close()
		}
	}
}

Function Main() {
	$server = "localhost"
	$port = "25"
	$mailfrom = "from@example.com"
	$rcptto = "to@example.com"
	$filename = "test.eml"

	SendMessage $server $port $mailfrom $rcptto $filename
}

Main | Out-Null
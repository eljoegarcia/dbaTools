Function Get-DbaLogin {
<#
	.SYNOPSIS 
	Function to get an SMO login object of the logins for a given SQL Instance. Takes a server object from the pipe 

	.DESCRIPTION
	The Get-DbaLogin function returns an SMO Login object for the logins passed, if there are no users passed it will return all logins.  

	.PARAMETER SqlInstance
	The SQL Server instance, or instances.You must have sysadmin access and server version must be SQL Server version 2000 or higher.

	.PARAMETER SqlCredential
	Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. 

	.PARAMETER Login
	Pass a single login, or a list of them. Comma delimited. 

	.PARAMETER Locked 
	Filters on the SMO property to return locked Logins. 

	.PARAMETER Disabled 
	Filters on the SMO property to return disabled Logins. 

	.PARAMETER HasAccess 
	Filters on the SMO property to return Logins that has access to the instance of SQL Server. 

	.PARAMETER Silent 
	Use this switch to disable any kind of verbose messages

	.NOTES 
	Original Author: Mitchell Hamann (@SirCaptainMitch)

	Website: https://dbatools.io
	Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
	License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

	.LINK
	https://dbatools.io/Get-DbaLogin

	.EXAMPLE
	Get-DbaLogin -SqlInstance SQl2016 
	Gets all the logins for a given SQL Server using NT authentication and returns the SMO login objects 

	.EXAMPLE   
	Get-DbaLogin -SqlInstance SQl2016 -SqlCredential $sqlcred 
	Gets all the logins for a given SQL Server using a passed credential object and returns the SMO login objects 

	.EXAMPLE 
	Get-DbaLogin -SqlInstance SQl2016 -SqlCredential $sqlcred -Login dbatoolsuser,TheCaptain 
	Get specific user objects from the server

	.EXAMPLE 
	'sql2016', 'sql2014' | Get-DbaLogin -SqlCredential $sqlcred 
	Using Get-DbaLogin on the pipeline, you can also specify which names you would like with -Logins.

	.EXAMPLE 
	'sql2016', 'sql2014' | Get-DbaLogin -SqlCredential $sqlcred -Locked
	Using Get-DbaLogin on the pipeline to get all locked Logins 

	.EXAMPLE 
	'sql2016', 'sql2014' | Get-DbaLogin -SqlCredential $sqlcred -HasAccess
	Using Get-DbaLogin on the pipeline to get all logins that have access to that instance 

	.EXAMPLE 
	'sql2016', 'sql2014' | Get-DbaLogin -SqlCredential $sqlcred -Disabled
	Using Get-DbaLogin on the pipeline to get all Disabled Logins 
	
#>
	[CmdletBinding()]
	Param (
		[parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlServer")]
		[object[]]$SqlInstance,
		[System.Management.Automation.PSCredential]$SqlCredential,
		[Object[]]$Login,
		[Switch]$HasAccess,
		[Switch]$Locked,
		[Switch]$Disabled,
		[Switch]$Silent
	)
	
	process {
		foreach ($Instance in $sqlInstance) {
			try {
				Write-Message -Level Verbose -Message "Connecting to $instance"
				$server = Connect-SqlServer -SqlServer $instance -SqlCredential $sqlcredential
			}
			catch {
				Stop-Function -Message "Failed to connect to: $instance" -Continue -Target $instance
			}
			
			if ($Login -ne $null) {
				$serverLogins = $server.Logins | Where-Object { $Login -contains $_.name }
			}
			elseif ($HasAccess) {
				$serverLogins = $server.Logins | Where-Object { $_.HasAccess -eq $true }
			}
			elseif ($Locked) {
				$serverLogins = $server.Logins | Where-Object { $_.IsLocked -eq $true }
			}
			elseif ($Disabled) { $serverLogins = $server.Logins | Where-Object { $_.IsDisabled -eq $true }
			}
			else {
				$serverLogins = $server.Logins
			}
			
			foreach ($serverLogin in $serverlogins) {
				
				Write-Message -Level Verbose -Message "Processing $serverLogin on $instance"
				Write-Message -Level Verbose -Message "Getting last login time"
				$sql = "SELECT MAX(login_time) AS [login_time] FROM sys.dm_exec_sessions WHERE login_name = '$($serverLogin.name)'"
				
				Add-Member -InputObject $serverLogin -MemberType NoteProperty -Name LastLogin -Value $server.ConnectionContext.ExecuteScalar($sql)
				Add-Member -InputObject $serverLogin -MemberType NoteProperty -Name ComputerName -Value $server.NetName
				Add-Member -InputObject $serverLogin -MemberType NoteProperty -Name InstanceName -Value $server.ServiceName
				Add-Member -InputObject $serverLogin -MemberType NoteProperty -Name SqlInstance -Value $server.DomainInstanceName
				
				if ($Detailed) {
					Select-DefaultView -InputObject $serverLogin -Property ComputerName, InstanceName, SqlInstance, Name, LoginType, LastLogin
				}
				elseif ($HasAccess) {
					Select-DefaultView -InputObject $serverLogin -Property ComputerName, InstanceName, SqlInstance, Name, LoginType, LastLogin, HasAccess
				}
				elseif ($Locked) {
					Select-DefaultView -InputObject $serverLogin -Property ComputerName, InstanceName, SqlInstance, Name, LoginType, LastLogin, IsLocked
				}
				elseIf ($Disabled) {
					Select-DefaultView -InputObject $serverLogin -Property ComputerName, InstanceName, SqlInstance, Name, LoginType, LastLogin, IsDisabled
				}
				else {
					Select-DefaultView -InputObject $serverLogin -Property ComputerName, InstanceName, SqlInstance, Name, LoginType, LastLogin
				}
			}
		}
	}
}
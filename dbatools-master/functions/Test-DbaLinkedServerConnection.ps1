function Test-DbaLinkedServerConnection
{
<#
.SYNOPSIS
Test all linked servers from the sql servers passed

.DESCRIPTION
Test each linked server on the instance

.PARAMETER SqlInstance
The SQL Server that you're connecting to.

.PARAMETER SqlCredential
Credential object used to connect to the SQL Server as a different user

.PARAMETER Silent 
Use this switch to disable any kind of verbose messages
	
.NOTES
Author: Thomas LaRock ( https://thomaslarock.com )
	
dbatools PowerShell module (https://dbatools.io)
Copyright (C) 2017 Chrissy LeMaire
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
.LINK
https://dbatools.io/Test-DbaLinkedServerConnection

.EXAMPLE
Test-DbaLinkedServerConnection -SqlInstance DEV01

Test all Linked Servers for the SQL Server instance DEV01

.EXAMPLE
Test-DbaLinkedServerConnection -SqlInstance sql2016 | Out-File C:\temp\results.txt

Test all Linked Servers for the SQL Server instance sql2016 and output results to file

.EXAMPLE
Test-DbaLinkedServerConnection -SqlInstance sql2016, sql2014, sql2012

Test all Linked Servers for the SQL Server instances sql2016, sql2014 and sql2012

.EXAMPLE
$servers = "sql2016","sql2014","sql2012"
$servers | Test-DbaLinkedServerConnection -SqlCredential (Get-Credential sqladmin)

Test all Linked Servers for the SQL Server instances sql2016, sql2014 and sql2012 using SQL login credentials
	
.EXAMPLE
$servers | Get-DbaLinkedServer | Test-DbaLinkedServerConnection

Test all Linked Servers for the SQL Server instances sql2016, sql2014 and sql2012

#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[Alias("ServerInstance", "SqlServer")]
		[object[]]$SqlInstance,
		[System.Management.Automation.PSCredential]$SqlCredential,
		[switch]$Silent
	)
	
	begin {
		$LinkedServerCollection = @()
	}
	
	process {
		foreach ($Instance in $SqlInstance) {
			
			# This is a very ugly workaround until we finish the dbaserver custom parameter type.
			# Don't judge! ;) - Chrissy
			if ($Instance.GetType().Name -eq 'LinkedServer') {
				$LinkedServerCollection += $Instance
				continue
			}
			
			try {
				Write-Message -Level Verbose -Message "Connecting to $instance"
				$server = Connect-SqlServer -SqlServer $instance -SqlCredential $sqlcredential
			}
			catch {
				Stop-Function -Message "Failed to connect to: $instance" -Continue -Target $instance
			}
			
			$LinkedServerCollection += $server.LinkedServers
		}
	}
	
	end {
		foreach ($ls in $LinkedServerCollection) {
			Write-Message -Level Verbose -Message "Testing linked server $($ls.name) on server $($ls.parent.name)"
			try {
				$null = $ls.TestConnection()
				$result = "Success"
				$connectivity = $true
			}
			catch {
				$result = $_.Exception.InnerException.InnerException.Message
				$connectivity = $false
			}
			
			[PSCustomObject]@{
				ComputerName = $ls.parent.NetName
				InstanceName = $ls.parent.ServiceName
				SqlInstance = $ls.parent.DomainInstanceName
				LinkedServerName = $ls.Name
				RemoteServer = $ls.DataSource
				Connectivity = $connectivity
				Result = $result
			} | Select-DefaultView -ExcludeProperty ComputerName, InstanceName
		}
	}
}
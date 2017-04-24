FUNCTION Get-DbaAudit
{
<#
.SYNOPSIS
Gets SQL Security Audit information for each instance(s) of SQL Server.

.DESCRIPTION
 The Get-DbaAudit command gets SQL Security Audit information for each instance(s) of SQL Server.
	
.PARAMETER SqlInstance
SQL Server name or SMO object representing the SQL Server to connect to. This can be a collection and recieve pipeline input to allow the function
to be executed against multiple SQL Server instances.

.PARAMETER Credential
PSCredential object to connect as. If not specified, current Windows login will be used.

.NOTES
Author: Garry Bargsley (@gbargsley), http://blog.garrybargsley.com

dbatools PowerShell module (https://dbatools.io, clemaire@gmail.com)
Copyright (C) 2016 Chrissy LeMaire
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.	

.LINK
https://dbatools.io/Get-DbaAudit

.EXAMPLE
Get-DbaAudit -SqlInstance localhost
Returns all Security Audits on the local default SQL Server instance

.EXAMPLE
Get-DbaAudit -SqlInstance localhost, sql2016
Returns all Security Audits for the local and sql2016 SQL Server instances

#>
	[CmdletBinding()]
	Param (
		[parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $True)]
		[object]$SqlInstance,
		[System.Management.Automation.PSCredential]$Credential
	)
	
	PROCESS
	{
		foreach ($instance in $SqlInstance)
		{
			Write-Verbose "Attempting to connect to $instance"
			try
			{
				$server = Connect-SqlServer -SqlServer $instance -SqlCredential $Credential
			}
			catch
			{
				Write-Warning "Can't connect to $instance or access denied. Skipping."
				continue
			}
			
			if ($server.versionMajor -lt 10)
			{
				Write-Warning "Server Audits are only supported in SQL Server 2008 and above. Quitting."
				continue
			}
			
			foreach ($audit in $server.Audits)
			{
				Add-Member -InputObject $audit -MemberType NoteProperty ComputerName -value $audit.Parent.NetName
				Add-Member -InputObject $audit -MemberType NoteProperty InstanceName -value $audit.Parent.ServiceName
				Add-Member -InputObject $audit -MemberType NoteProperty SqlInstance -value $audit.Parent.DomainInstanceName
				
				Select-DefaultView -InputObject $audit -Property ComputerName, InstanceName, SqlInstance, Name, 'Enabled as IsEnabled', FilePath, FileName
			}
		}
	}
}

#ValidationTags#FlowControl,Pipeline#
function Get-DbaSpn
{
<#
.SYNOPSIS
Returns a list of set service principal names for a given computer/AD account

.DESCRIPTION
Get a list of set SPNs. SPNs are set at the AD account level. You can either retrieve set SPNs for a computer, or any SPNs set for
a given active directry account. You can query one, or both. You'll get a list of every SPN found for either search term.

.PARAMETER ComputerName
The servers you want to return set SPNs for. This is defaulted automatically to localhost.

.PARAMETER AccountName
The accounts you want to retrieve set SPNs for.

.PARAMETER Credential
User credential to connect to the remote servers or active directory.

.PARAMETER Silent
Use this switch to disable any kind of verbose messages

.NOTES
Tags: SPN
Author: Drew Furgiuele (@pittfurg), http://www.port1433.com

dbatools PowerShell module (https://dbatools.io)
Copyright (C) 2016 Chrissy LeMaire
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

.LINK
https://dbatools.io/Get-DbaSpn

.EXAMPLE
Get-DbaSpn -ServerName SQLSERVERA -Credential (Get-Credential)

Returns a custom object with SearchTerm (ServerName) and the SPNs that were found

.EXAMPLE
Get-DbaSpn -AccountName domain\account -Credential (Get-Credential)

Returns a custom object with SearchTerm (domain account) and the SPNs that were found

.EXAMPLE
Get-DbaSpn -ServerName SQLSERVERA,SQLSERVERB -Credential (Get-Credential)

Returns a custom object with SearchTerm (ServerName) and the SPNs that were found for multiple computers
#>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory = $false,ValueFromPipeline = $true)]
		[string[]]$ComputerName,
		[Parameter(Mandatory = $false)]
		[string[]]$AccountName,
		[Parameter(Mandatory = $false)]
		[PSCredential]$Credential,
		[switch]$Silent
	)
	begin
	{
		Function Process-Account ($AccountName) {
			
			ForEach ($account in $AccountName)
			{
				Write-Message -Message "Looking for account $account..." -Level Verbose
				try
				{
					$Result = Get-DbaADObject -ADObject $account -Type User -Credential $Credential -Silent
				}
				catch
				{
					Write-Message -Message "AD lookup failure. This may be because the domain cannot be resolved for the SQL Server service account ($Account)." -Level Warning
					continue
				}
				if ($Result.Count -gt 0)
				{
					try {
						$results = $Result.GetUnderlyingObject()
						$spns = $results.Properties.servicePrincipalName
					} catch {
						Write-Message -Message "The SQL Service account ($serviceAccount) has been found, but you don't have enough permission to inspect its SPNs" -Level Warning
						continue
					}
				} else {
					Write-Message -Message "The SQL Service account ($serviceAccount) has not been found" -Level Warning
					continue
				}
				
				foreach ($spn in $spns)
				{
					if ($spn -match "\:")
					{
						try
						{
							$port = [int]($spn -Split "\:")[1]
						}
						catch
						{
							$port = $null
						}
						if ($spn -match "\/")
						{
							$serviceclass = ($spn -Split "\/")[0]
						}
					}
					[pscustomobject] @{
						Input = $account
						AccountName = $account
						ServiceClass = "MSSQLSvc" # $serviceclass
						Port = $port
						SPN = $spn
					}
				}
			}
		}
		if ($ComputerName.Count -eq 0 -and $AccountName.Count -eq 0) {
			$ComputerName = @($env:COMPUTERNAME)
		}
	}
	
	process
	{	
		
		foreach ($computer in $ComputerName)
		{
			if ($computer)
			{
				if ($computer.EndsWith('$'))
				{
					Write-Message -Message "$computer is an account name. Processing as account." -Level Verbose
					Process-Account -AccountName $computer
					continue
				}
			}
			
			Write-Message -Message "Getting SQL Server SPN for $computer" -Level Verbose
			$spns = Test-DbaSpn -ComputerName $computer -Credential $Credential
			
			$sqlspns = 0
			$spncount = $spns.count
			Write-Message -Message "Calculated $spncount SQL SPN entries that should exist for $computer" -Level Verbose
			foreach ($spn in $spns | Where-Object { $_.IsSet -eq $true })
			{
				$sqlspns++
				
				if ($accountName)
				{
					if ($accountName -eq $spn.InstanceServiceAccount)
					{
						[pscustomobject] @{
							Input = $computer
							AccountName = $spn.InstanceServiceAccount
							ServiceClass = "MSSQLSvc"
							Port = $spn.Port
							SPN = $spn.RequiredSPN
						}
					}
				}
				else
				{
					[pscustomobject] @{
						Input = $computer
						AccountName = $spn.InstanceServiceAccount
						ServiceClass = "MSSQLSvc"
						Port = $spn.Port
						SPN = $spn.RequiredSPN
					}
				}
			}
			Write-Message -Message "Found $sqlspns set SQL SPN entries for $computer" -Level Verbose
		}
		
		if ($AccountName)
		{
			foreach ($account in $AccountName)
			{
				Process-Account -AccountName $account
			}
		}
	}
}

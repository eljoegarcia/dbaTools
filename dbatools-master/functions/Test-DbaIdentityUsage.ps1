Function Test-DbaIdentityUsage
{
<# 
.SYNOPSIS 
Displays information relating to IDENTITY seed usage.  Works on SQL Server 2008 and above.

.DESCRIPTION 
IDENTITY seeds have max values based off of their data type.  This module will locate identity columns and report the seed usage.

.PARAMETER SqlInstance
Allows you to specify a comma separated list of servers to query.

.PARAMETER SqlCredential
Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. To use:
$cred = Get-Credential, this pass this $cred to the param. 

Windows Authentication will be used if DestinationSqlCredential is not specified. To connect as a different Windows user, run PowerShell as that user.	

.PARAMETER Threshold
Allows you to specify a minimum % of the seed range being utilized.  This can be used to ignore seeds that have only utilized a small fraction of the range.

.PARAMETER NoSystemDb
Allows you to suppress output on system databases

.PARAMETER Silent 
Use this switch to disable any kind of verbose messages

.NOTES 
Author: Brandon Abshire, netnerds.net
Tags: Identity

dbatools PowerShell module (https://dbatools.io, clemaire@gmail.com)
Copyright (C) 2016 Chrissy LeMaire
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

.LINK 
https://dbatools.io/Test-DbaIdentityUsage

.EXAMPLE   
Test-DbaIdentityUsage -SqlServer sql2008, sqlserver2012
Check identity seeds for servers sql2008 and sqlserver2012.

.EXAMPLE   
Test-DbaIdentityUsage -SqlServer sql2008 -Database TestDB
Check identity seeds on server sql2008 for only the TestDB database

.EXAMPLE   
Test-DbaIdentityUsage -SqlServer sql2008 -Database TestDB -Threshold 20
Check identity seeds on server sql2008 for only the TestDB database, limiting results to 20% utilization of seed range or higher


#>
	[CmdletBinding()]
	Param (
		[parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $True)]
		[Alias("ServerInstance", "SqlServer", "SqlServers")]
		[string[]]$SqlInstance,
		[System.Management.Automation.PSCredential]$SqlCredential,
		[parameter(Position = 1, Mandatory = $false)]
		[int]$Threshold = 0,
		[parameter(Position = 2, Mandatory = $false)]
		[switch]$NoSystemDb,
		[switch]$Silent
	)
	
	DynamicParam
	{
		if ($SqlInstance)
		{
			return Get-ParamSqlDatabases -SqlServer $SqlInstance[0] -SqlCredential $SqlCredential
		}
	}
	
	BEGIN
	{
		
		$databases = $psboundparameters.Databases
		$exclude = $psboundparameters.Exclude
		
		$threshold = $psboundparameters.Threshold
		
		$sql = ";WITH CTE_1
		AS
		(
		  SELECT SCHEMA_NAME(o.schema_id) AS SchemaName,
				 OBJECT_NAME(a.Object_id) as TableName,
				 a.Name as ColumnName,
				 seed_value AS SeedValue,
				 CONVERT(bigint, increment_value) as IncrementValue,

				 CONVERT(bigint, ISNULL(a.last_value, seed_value)) AS LastValue,

				 CONVERT(bigint,
								(
									CONVERT(bigint, ISNULL(last_value, seed_value)) 
									- CONVERT(bigint, seed_value) 
									+ (CASE WHEN CONVERT(bigint, seed_value) <> 0 THEN 1 ELSE 0 END) 
								)
								/
								CONVERT(bigint, increment_value)
						) AS NumberOfUses,

				 -- Divide by increment_value to shows the max number of values that can be used
				 -- E.g: smallint identity column that starts on the lower possible value (-32768) and have an increment of 2 will only accept ABS(32768 - 32767 - 1) / 2 = 32768 rows
				 CAST( 
						--ABS(
						CONVERT(bigint, seed_value) 
						- 
						Case
							When b.name = 'tinyint'   Then 255
							When b.name = 'smallint'  Then 32767
							When b.name = 'int'       Then 2147483647
							When b.name = 'bigint'    Then 9223372036854775807
						End 
						-
						-- When less than 0 the 0 counts too
						CASE 
							WHEN CONVERT(bigint, seed_value) <= 0 THEN 1
							ELSE 0
							END
						--) 
                        / CONVERT(bigint, increment_value) 
					AS Numeric(20, 0)) AS MaxNumberRows
			FROM sys.identity_columns a
				INNER JOIN sys.objects o
				   ON a.object_id = o.object_id
				INNER JOIN sys.types As b
				   ON a.system_type_id = b.system_type_id
		  WHERE a.seed_value is not null
		),
		CTE_2
		AS
		(
		SELECT SchemaName, TableName, ColumnName, CONVERT(BIGINT, SeedValue) AS SeedValue, CONVERT(BIGINT, IncrementValue) AS IncrementValue, LastValue, ABS(CONVERT(FLOAT,MaxNumberRows)) AS MaxNumberRows, NumberOfUses, 
			   CONVERT(Numeric(18,2), ((CONVERT(Float, NumberOfUses) / ABS(CONVERT(FLOAT,MaxNumberRows)) * 100))) AS [PercentUsed]
		  FROM CTE_1
		)
		SELECT DB_NAME() as DatabaseName, SchemaName, TableName, ColumnName, SeedValue, IncrementValue, LastValue, MaxNumberRows, NumberOfUses, [PercentUsed]
		  FROM CTE_2"

        If($Threshold -gt 0) { $sql += " WHERE [PercentUsed] >= " + $Threshold + " ORDER BY [PercentUsed] DESC" }
        Else { $sql += " ORDER BY [PercentUsed] DESC" }
		
	}
	
	PROCESS
	{
		
		foreach ($instance in $SqlInstance)
		{
			Write-Message -Level Verbose -Message "Attempting to connect to $instance"
			
			try
			{
				$server = Connect-SqlServer -SqlServer $instance -SqlCredential $SqlCredential
			}
			catch
			{
				Stop-Function -Message "Can't connect to $instance or access denied. Skipping." -Continue
			}
			
			if ($server.versionMajor -lt 10)
			{
				Stop-Function -Message "This function does not support versions lower than SQL Server 2008 (v10). Skipping server $instance." -Continue
			}
			
			
			$dbs = $server.Databases
			
			if ($databases.count -gt 0)
			{
				$dbs = $dbs | Where-Object { $databases -contains $_.Name }
			}
			
			if ($exclude.count -gt 0)
			{
				$dbs = $dbs | Where-Object { $exclude -notcontains $_.Name }
			}
			
			if ($NoSystemDb)
			{
				$dbs = $dbs | Where-Object { $_.IsSystemObject -eq $false }
			}
			
			foreach ($db in $dbs)
			{
				Write-Message -Level Verbose -Message "Processing $db on $instance"
				
				if ($db.IsAccessible -eq $false)
				{
					Stop-Function -Message "The database $db is not accessible. Skipping database." -Continue
				}
				
				foreach ($row in $db.ExecuteWithResults($sql).Tables[0])
				{
					if ($row.PercentUsed -eq [System.DBNull]::Value)
					{
						continue
					}
					
					if ($row.PercentUsed -ge $threshold)
					{
						[PSCustomObject]@{
							ComputerName = $server.NetName
							InstanceName = $server.ServiceName
							SqlInstance = $server.DomainInstanceName
							Database = $row.DatabaseName
							Schema = $row.SchemaName
							Table = $row.TableName
							Column = $row.ColumnName
							SeedValue = $row.SeedValue
							IncrementValue = $row.IncrementValue
							LastValue = $row.LastValue
							MaxNumberRows = $row.MaxNumberRows
							NumberOfUses = $row.NumberOfUses
							PercentUsed = $row.PercentUsed
						}
					}
				}
			}
		}
	}
}

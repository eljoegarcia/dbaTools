﻿Function Invoke-DbaDatabaseShrink
{
<#
.SYNOPSIS
Shrinks all files in a database. This is a command that should rarely be used.

- Shrinks can cause severe index fragmentation (to the tune of 99%)
- Shrinks can cause massive growth in the database's transaction log
- Shrinks can require a lot of time and system resources to perform data movement

.DESCRIPTION
Shrinks all files in a database. Databases should be shrunk only when completely necessary.
	
Many awesome SQL people have written about why you should not shrink your data files. Paul Randal and Kalen Delaney wrote great posts about this topic:
	
	http://www.sqlskills.com/blogs/paul/why-you-should-not-shrink-your-data-files
	http://sqlmag.com/sql-server/shrinking-data-files

However, there are some cases where a database will need to be shrunk. In the event that you must shrink your database:
	
1. Ensure you have plenty of space for your T-Log to grow
2. Understand that shrinks require a lot of CPU and disk resources
3. Consider running DBCC INDEXDEFRAG or ALTER INDEX ... REORGANIZE after the shrink is complete.
	
.PARAMETER SqlInstance
The SQL Server that you're connecting to.

.PARAMETER SqlCredential
SqlCredential object used to connect to the SQL Server as a different user.

.PARAMETER Databases
Shrink specific databases.

.PARAMETER Exclude
Shrink all databases on the connected server except databases entered through this parameter.

.PARAMETER AllUserDatabases
Run command against all user databases	
	
.PARAMETER PercentFreeSpace
Specifies how much to reduce the database in percent, defaults to 0.

.PARAMETER ShrinkMethod
Specifies the method that is used to shrink the database
	
		Default	
			Data in pages located at the end of a file is moved to pages earlier in the file. Files are truncated to reflect allocated space.
		EmptyFile	
			Migrates all of the data from the referenced file to other files in the same filegroup. (DataFile and LogFile objects only).
		NoTruncate	
			Data in pages located at the end of a file is moved to pages earlier in the file.
		TruncateOnly	
			Data distribution is not affected. Files are truncated to reflect allocated space, recovering free space at the end of any file.

.PARAMETER StatementTimeout
Timeout in minutes. Defaults to infinity (shrinks can take a while.)

.PARAMETER WhatIf
Shows what would happen if the command were to run
	
.PARAMETER Confirm
Prompts for confirmation of every step. For example:

Are you sure you want to perform this action?
Performing the operation "Shrink database" on target "pubs on SQL2016\VNEXT".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):

.PARAMETER Silent 
Use this switch to disable any kind of verbose messages

.NOTES
Tags: Shrink, Database
dbatools PowerShell module (https://dbatools.io)
Copyright (C) 2016 Chrissy LeMaire
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

.LINK
https://dbatools.io/Invoke-DbaDatabaseShrink

.EXAMPLE
Invoke-DbaDatabaseShrink -SqlInstance sql2016 -Databases Northwind,pubs,Adventureworks2014

Shrinks Northwind, pubs and Adventureworks2014 to have as little free space as possible.

.EXAMPLE
Invoke-DbaDatabaseShrink -SqlInstance sql2014 -Databases Adventureworks2014 -PercentFreeSpace 50

Shrinks Adventureworks2014 to have 50% free space. So let's say Adventureworks2014 was 1GB and it's using 100MB space. The database free space would be reduced to 50MB.

.EXAMPLE
Invoke-DbaDatabaseShrink -SqlInstance sql2012 -AllUserDatabase

Shrinks all databases on SQL2012 (not ideal for production)

#>
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	Param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlServer")]
		[object[]]$SqlInstance,
		[PsCredential]$SqlCredential,
		[switch]$AllUserDatabases,
		[ValidateRange(0, 99)]
		[int]$PercentFreeSpace = 0,
		[ValidateSet('Default', 'EmptyFile', 'NoTruncate', 'TruncateOnly')]
		[string]$ShrinkMethod = "Default",
		[int]$StatementTimeout = 0,
		[switch]$Silent
	)
	
	DynamicParam
	{
		if ($SqlInstance)
		{
			Get-ParamSqlDatabases -SqlServer $SqlInstance[0] -SqlCredential $SqlCredential
		}
		
		# change from mins to seconds, as needed by Server.ConnectionContext.StatementTimeout
		$StatementTimeoutMinutes = $StatementTimeout * 60
	}
	
	BEGIN
	{
		# Convert from RuntimeDefinedParameter object to regular array
		$databases = $psboundparameters.Databases
		$exclude = $psboundparameters.Exclude
		
		$sql = "SELECT 
				indexstats.avg_fragmentation_in_percent
				FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
				INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
				INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
				INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
				AND indexstats.index_id = dbindexes.index_id
				WHERE indexstats.database_id = DB_ID() AND indexstats.avg_fragmentation_in_percent > 0
				ORDER BY indexstats.avg_fragmentation_in_percent desc"
		
		$sqltop1 = "SELECT top 1
				indexstats.avg_fragmentation_in_percent
				FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
				INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
				INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
				INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
				AND indexstats.index_id = dbindexes.index_id
				WHERE indexstats.database_id = DB_ID()
				ORDER BY indexstats.avg_fragmentation_in_percent desc"
	}
	
	PROCESS
	{
		if (!$databases -and !$exclude -and !$AllUserDatabases)
		{
			Stop-Function -Message "You must specify databases to execute against using either -Databases, -Exclude or -AllUserDatabases" -Continue
		}
		
		foreach ($instance in $SqlInstance)
		{
			Write-Message -Level Verbose -Message "Connecting to $instance"
			try
			{
				$server = Connect-SqlServer -SqlServer $instance -SqlCredential $SqlCredential
				
			}
			catch
			{
				Stop-Function -Message "Can't connect to $instance. Moving on." -Continue
			}
			
			# changing statement timeout to $StatementTimeout
			if ($StatementTimeout -eq 0)
			{
				Write-Message -Level Verbose -Message "Changing statement timeout to infinity"
			}
			else
			{
				Write-Message -Level Verbose -Message "Changing statement timeout to $StatementTimeout minutes"
			}
			$server.ConnectionContext.StatementTimeout = $StatementTimeout
			
			$dbs = $server.Databases | Where-Object { $_.IsSystemObject -eq $false }
			
			if ($databases)
			{
				$dbs = $dbs | Where-Object { $databases -contains $_.Name }
			}
			
			if ($exclude)
			{
				$dbs = $dbs | Where-Object { $exclude -notcontains $_.Name }
			}
			
			foreach ($db in $dbs)
			{
				Write-Message -Level Verbose -Message "Processing $db on $instance"
				
				if ($db.IsAccessible -eq $false)
				{
					Stop-Function -Message "The database $db on server $instance is not accessible. Skipping database." -Continue
				}
				
				$startingsize = $db.Size
				$spaceAvailableMB = $db.SpaceAvailable/1024
				$spaceused = $startingsize - $spaceAvailableMB
				$desiredSpaceAvailable = ($PercentFreeSpace * $spaceused)/100
				
				Write-Message -Level Verbose -Message "Starting Size (MB): $startingsize"
				Write-Message -Level Verbose -Message "Starting Freespace (MB): $([int]$spaceavailableMB)"
				Write-Message -Level Verbose -Message "Desired Freespace (MB): $([int]$desiredSpaceAvailable)"
				
				if (($db.SpaceAvailable/1024) -le $desiredSpaceAvailable)
				{
					Write-Message -Level Warning -Message "Space Available ($spaceavailableMB) is less than or equal to the desired outcome ($desiredSpaceAvailable)"
				}
				else
				{
					if ($Pscmdlet.ShouldProcess("$db on $instance", "Shrinking from $([int]$spaceavailableMB) MB space available to $([int]$desiredSpaceAvailable) MB space available"))
					{
						if ($db.Tables.Indexes.Name -and $server.VersionMajor -gt 8)
						{
							Write-Message -Level Verbose -Message "Getting average fragmentation"
							$startingfrag = (Invoke-Sqlcmd2 -ServerInstance $instance -Credential $SqlCredential -Query $sql -Database $db.name -Verbose:$false | Select-Object -ExpandProperty avg_fragmentation_in_percent | Measure-Object -Average).Average
							$startingtopfrag = (Invoke-Sqlcmd2 -ServerInstance $instance -Credential $SqlCredential -Query $sqltop1 -Database $db.name -Verbose:$false).avg_fragmentation_in_percent
						}
						else
						{
							$startingtopfrag = $startingfrag = $null
						}
						
						$start = Get-Date
						
						try
						{
							Write-Message -Level Verbose -Message "Beginning shrink"
							$db.Shrink($PercentFreeSpace, $ShrinkMethod)
							$db.Refresh()
							Write-Message -Level Verbose -Message "Recalculating space usage"
							$db.RecalculateSpaceUsage()
							$success = $true
							$notes = $null
						}
						catch
						{
							$success = $false
							$notes = $_.Exception.InnerException
						}
						
						$end = Get-Date
						$dbsize = $db.Size
						$newSpaceAvailableMB = $db.SpaceAvailable/1024						
						
						Write-Message -Level Verbose -Message "Final database size: $([int]$dbsize) MB"
						Write-Message -Level Verbose -Message "Final space available: $([int]$newSpaceAvailableMB) MB"
						
						if ($db.Tables.Indexes.Name -and $server.VersionMajor -gt 8)
						{
							Write-Message -Level Verbose -Message "Refreshing indexes and getting average fragmentation"
							$endingdefrag = (Invoke-Sqlcmd2 -ServerInstance $instance -Credential $SqlCredential -Query $sql -Database $db.name -Verbose:$false | Select-Object -ExpandProperty avg_fragmentation_in_percent | Measure-Object -Average).Average
							$endingtopfrag = (Invoke-Sqlcmd2 -ServerInstance $instance -Credential $SqlCredential -Query $sqltop1 -Database $db.name -Verbose:$false).avg_fragmentation_in_percent
						}
						else
						{
							$endingtopfrag = $endingdefrag = $null
						}
						
						$timespan = New-TimeSpan -Start $start -End $end
						$ts = [timespan]::fromseconds($timespan.TotalSeconds)
						$elapsed = "{0:HH:mm:ss}" -f ([datetime]$ts.Ticks)
					}
				}
				
				#$db.TruncateLog()
				
				if ($Pscmdlet.ShouldProcess("$db on $instance", "Showing results"))
				{					
					if ($null -eq $notes)
					{
						$notes = "Database shrinks can cause massive index fragmentation and negatively impact performance. You should now run DBCC INDEXDEFRAG or ALTER INDEX ... REORGANIZE"
					}
					
					[pscustomobject]@{
						ComputerName = $server.NetName
						InstanceName = $server.ServiceName
						SqlInstance = $server.DomainInstanceName
						Database = $db.name
						Start = $start
						End = $end
						Elapsed = $elapsed
						Success = $success
						StartingTotalSizeMB = [math]::Round($startingsize, 2)
						CurrentlyUsedMB = [math]::Round($spaceused, 2)
						FinalTotalSizeMB = [math]::Round($db.size, 2)
						CurrentlyAvailableMB = [math]::Round($spaceavailableMB, 2)
						DesiredAvailableMB = [math]::Round($desiredSpaceAvailable, 2)
						FinalAvailableMB = [math]::Round(($db.SpaceAvailable/1024), 2)
						StartingAvgIndexFragmentation = [math]::Round($startingfrag, 1)
						EndingAvgIndexFragmentation = [math]::Round($endingdefrag, 1)
						StartingTopIndexFragmentation = [math]::Round($startingtopfrag, 1)
						EndingTopIndexFragmentation = [math]::Round($endingtopfrag, 1)
						Notes = $notes
					}
				}
			}
		}
	}
}
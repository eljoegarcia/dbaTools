Function Find-DbaDatabaseGrowthEvent
{
<#
.SYNOPSIS
Finds any database AutoGrow events in the Default Trace.
	
.DESCRIPTION
Finds any database AutoGrow events in the Default Trace.
	
.PARAMETER SqlInstance
The SQL Server that you're connecting to.

.PARAMETER SqlCredential
SqlCredential object used to connect to the SQL Server as a different user.

.NOTES
Author: Aaron Nelson
Tags: AutoGrow
dbatools PowerShell module (https://dbatools.io)
Copyright (C) 2016 Chrissy LeMaire
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
Query Extracted from SQL Server Management Studio (SSMS) 2016.

.LINK
https://dbatools.io/Find-DbaDatabaseGrowthEvent

.EXAMPLE
Find-DBADatabaseGrowthEvent -SqlServer localhost

Returns any database AutoGrow events in the Default Trace for every database on the localhost instance.

.EXAMPLE
Find-DBADatabaseGrowthEvent -SqlServer ServerA\SQL2016, ServerA\SQL2014

Returns any database AutoGrow events in the Default Traces for every database on ServerA\sql2016 & ServerA\SQL2014.

.EXAMPLE
Find-DBADatabaseGrowthEvent -SqlServer ServerA\SQL2016 | Format-Table -AutoSize -Wrap

Returns any database AutoGrow events in the Default Trace for every database on the ServerA\SQL2016 instance in a table format.
	
#>
	[CmdletBinding()]
	Param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlServer")]
		[object[]]$SqlInstance,
		[System.Management.Automation.PSCredential]$SqlCredential
	)
	
	DynamicParam { if ($SqlInstance) { return Get-ParamSqlDatabases -SqlServer $SqlInstance[0] -SqlCredential $SqlCredential } }
	
	begin
	{
		$databases = $psboundparameters.Databases
		$exclude = $psboundparameters.Exclude
		
		$query = "begin try  
                    if (select convert(int,value_in_use) from sys.configurations where name = 'default trace enabled' ) = 1 
                    begin 
                    declare @curr_tracefilename varchar(500) ; 
                    declare @base_tracefilename varchar(500) ; 
                    declare @indx int ;

                    select @curr_tracefilename = path from sys.traces where is_default = 1 ; 
                    set @curr_tracefilename = reverse(@curr_tracefilename);
                    select @indx  = patindex('%\%', @curr_tracefilename) ;
                    set @curr_tracefilename = reverse(@curr_tracefilename) ;
                    set @base_tracefilename = left( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc' ;  

                    select SERVERPROPERTY('MachineName') AS ComputerName, SERVERPROPERTY('InstanceName') AS InstanceName, SERVERPROPERTY('ServerName') AS SqlInstance
					,		CONVERT(INT,(dense_rank() over (order by StartTime desc))%2) as OrderRank
                    ,       convert(int, EventClass) as EventClass
                    ,       DatabaseName
                    ,       Filename
                    ,       CONVERT(INT,(Duration/1000)) as Duration
                    ,       dateadd (minute, datediff (minute, getdate(), getutcdate()), StartTime) as StartTime  -- Convert to UTC time
                    ,       dateadd (minute, datediff (minute, getdate(), getutcdate()), EndTime) as EndTime  -- Convert to UTC time
                    ,       (IntegerData*8.0/1024) as ChangeInSize 
                    from ::fn_trace_gettable( @base_tracefilename, default ) 
                    where EventClass >=  92      and EventClass <=  95        and ServerName = @@servername   --and DatabaseName = @DatabaseName
                    order by StartTime desc ;   
                    end     else    
                    select -1 as OrderRank, 0 as EventClass, 0 DatabaseName, 0 as Filename, 0 as Duration, 0 as StartTime, 0 as EndTime,0 as ChangeInSize 
                    end try 
                    begin catch 
                    select -100 as OrderRank
                    ,       ERROR_NUMBER() as EventClass
                    ,       ERROR_SEVERITY() DatabaseName
                    ,       ERROR_STATE() as Filename
                    ,       ERROR_MESSAGE() as Duration
                    ,       1 as StartTime, 1 as EndTime,1 as ChangeInSize 
                    end catch"
	}
	
	process
	{
		foreach ($instance in $SqlInstance)
		{
			Write-Verbose "Connecting to $instance"
			try
			{
				$server = Connect-SqlServer -SqlServer $instance -SqlCredential $SqlCredential
				
			}
			catch
			{
				Write-Warning "Can't connect to $instance. Moving on."
				continue
			}
			
			$dbs = $server.Databases
			
			if ($databases)
			{
				$dbs = $dbs | Where-Object { $_.Name -in $databases }
			}
			
			if ($exclude)
			{
				$dbs = $dbs | Where-Object { $_.Name -notin $exclude }
			}
			
			foreach ($db in $dbs)
			{
				if ($db.IsAccessible -eq $false)
				{
					Write-Warning "The database $db on server $instance is not accessible. Skipping database."
					Continue
				}
				
				$db.ExecuteWithResults($query).Tables | Select-DefaultView -Property ComputerName, InstanceName, SqlInstance, EventClass, DatabaseName, Filename, Duration, StartTime, EndTime, ChangeInSize
			}
		}
	}
}

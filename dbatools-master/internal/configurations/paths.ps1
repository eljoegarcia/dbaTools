<#
This is designed for all paths you need configurations for.
#>

# The default path where dbatools stores persistent data
Set-DbaConfig -Name 'Path.DbatoolsData' -Value "$env:AppData\PowerShell\dbatools" -Default -DisableHandler -Description "The path where dbatools stores persistent data on a per user basis."

# The default path where dbatools stores temporary data
Set-DbaConfig -Name 'Path.DbatoolsTemp' -Value ([System.IO.Path]::GetTempPath()).TrimEnd("\") -Default -DisableHandler -Description "The path where dbatools stores temporary data."

# The default path for writing logs
Set-DbaConfig -Name 'Path.DbatoolsLogPath' -Value "$($env:AppData)\PowerShell\dbatools" -Default -Description "The path where dbatools writes all its logs and debugging information."

# The default Path for where the tags Json is stored
Set-DbaConfig -Name 'Path.TagCache' -Value ("$(Resolve-Path $configpath\..\..\bin)\dbatools-index.json") -Default -Description "The file in which dbatools stores the tag cache. That cache is used in Find-DbaCommand for more comfortable autocomplete"

# The default Path for the server list (Get-DbaServerList, etc)
Set-DbaConfig -Name 'Path.Servers' -Value "$env:AppData\PowerShell\dbatools\servers.xml" -Default -Description "The file in which dbatools stores the current user's server list, as managed by Get/Add/Update-DbaServerList"

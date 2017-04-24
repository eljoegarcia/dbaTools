#region message.maximuminfo
$ScriptBlock = {
    Param (
        $Value
    )
    
    $Result = New-Object PSOBject -Property @{
        Success = $True
        Message = ""
    }
    
    try { [int]$number = $Value }
    catch
    {
        $Result.Message = "Not an integer: $Value"
        $Result.Success = $False
        return $Result
    }
    
    if (($number -lt 0) -or ($number -gt 9))
    {
        $Result.Message = "Out of range. Either specify a number ranging from 1 to 9, or disable it by setting it to 0"
        $Result.Success = $False
        return $Result
    }
    
    [sqlcollective.dbatools.dbaSystem.MessageHost]::MaximumInformation = $Value
    
    return $Result
}
Register-DbaConfigHandler -Name 'message.maximuminfo' -ScriptBlock $ScriptBlock
#endregion message.maximuminfo

#region message.maximumverbose
$ScriptBlock = {
    Param (
        $Value
    )
    
    $Result = New-Object PSOBject -Property @{
        Success = $True
        Message = ""
    }
    
    try { [int]$number = $Value }
    catch
    {
        $Result.Message = "Not an integer: $Value"
        $Result.Success = $False
        return $Result
    }
    
    if (($number -lt 0) -or ($number -gt 9))
    {
        $Result.Message = "Out of range. Either specify a number ranging from 1 to 9, or disable it by setting it to 0"
        $Result.Success = $False
        return $Result
    }
    
    [sqlcollective.dbatools.dbaSystem.MessageHost]::MaximumVerbose = $Value
    
    return $Result
}
Register-DbaConfigHandler -Name 'message.maximumverbose' -ScriptBlock $ScriptBlock
#endregion message.maximumverbose

#region message.maximumdebug
$ScriptBlock = {
    Param (
        $Value
    )
    
    $Result = New-Object PSOBject -Property @{
        Success = $True
        Message = ""
    }
    
    try { [int]$number = $Value }
    catch
    {
        $Result.Message = "Not an integer: $Value"
        $Result.Success = $False
        return $Result
    }
    
    if (($number -lt 0) -or ($number -gt 9))
    {
        $Result.Message = "Out of range. Either specify a number ranging from 1 to 9, or disable it by setting it to 0"
        $Result.Success = $False
        return $Result
    }
    
    [sqlcollective.dbatools.dbaSystem.MessageHost]::MaximumDebug = $Value
    
    return $Result
}
Register-DbaConfigHandler -Name 'message.maximumdebug' -ScriptBlock $ScriptBlock
#endregion message.maximumdebug

#region message.minimuminfo
$ScriptBlock = {
    Param (
        $Value
    )
    
    $Result = New-Object PSOBject -Property @{
        Success = $True
        Message = ""
    }
    
    try { [int]$number = $Value }
    catch
    {
        $Result.Message = "Not an integer: $Value"
        $Result.Success = $False
        return $Result
    }
    
    if (($number -lt 0) -or ($number -gt 9))
    {
        $Result.Message = "Out of range. Either specify a number ranging from 1 to 9, or disable it by setting it to 0"
        $Result.Success = $False
        return $Result
    }
    
    [sqlcollective.dbatools.dbaSystem.MessageHost]::MinimumInformation = $Value
    
    return $Result
}
Register-DbaConfigHandler -Name 'message.minimuminfo' -ScriptBlock $ScriptBlock
#endregion message.minimuminfo

#region message.minimumverbose
$ScriptBlock = {
    Param (
        $Value
    )
    
    $Result = New-Object PSOBject -Property @{
        Success = $True
        Message = ""
    }
    
    try { [int]$number = $Value }
    catch
    {
        $Result.Message = "Not an integer: $Value"
        $Result.Success = $False
        return $Result
    }
    
    if (($number -lt 0) -or ($number -gt 9))
    {
        $Result.Message = "Out of range. Either specify a number ranging from 1 to 9, or disable it by setting it to 0"
        $Result.Success = $False
        return $Result
    }
    
    [sqlcollective.dbatools.dbaSystem.MessageHost]::MinimumVerbose = $Value
    
    return $Result
}
Register-DbaConfigHandler -Name 'message.minimumverbose' -ScriptBlock $ScriptBlock
#endregion message.minimumverbose

#region message.minimumdebug
$ScriptBlock = {
    Param (
        $Value
    )
    
    $Result = New-Object PSOBject -Property @{
        Success = $True
        Message = ""
    }
    
    try { [int]$number = $Value }
    catch
    {
        $Result.Message = "Not an integer: $Value"
        $Result.Success = $False
        return $Result
    }
    
    if (($number -lt 0) -or ($number -gt 9))
    {
        $Result.Message = "Out of range. Either specify a number ranging from 1 to 9, or disable it by setting it to 0"
        $Result.Success = $False
        return $Result
    }
    
    [sqlcollective.dbatools.dbaSystem.MessageHost]::MinimumDebug = $Value
    
    return $Result
}
Register-DbaConfigHandler -Name 'message.minimumdebug' -ScriptBlock $ScriptBlock
#endregion message.minimumdebug


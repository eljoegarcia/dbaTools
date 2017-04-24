﻿function Write-Message
{
    <#
        .SYNOPSIS
            This function acts as central information node for dbatools.
        
        .DESCRIPTION
            This function acts as central information node for dbatools.
            Other functions hand off all their information output for processing to this function.
            
            This function will then handle:
            - Warning output
            - Error management for non-terminating errors (For errors that terminate execution or continue on with the next object use "Stop-Function")
            - Logging
            - Verbose output
            - Message output to users
            
            At what complexity what path for the information is chosen is determined by the configuration settings:
            message.maximuminfo
            message.maximumverbose
            message.maximumdebug
            message.minimuminfo
            message.minimumverbose
            message.minimumdebug
            Which can be set to any level from 1 through 9
            Depending on the configuration it is very possible to have multiple paths chosen simultaneously
        
        .PARAMETER Message
            The message to write/log. The function name and timestamp will automatically be prepended.
        
        .PARAMETER Level
            This parameter represents the verbosity of the message. The lower the number, the more important it is for a human user to read the message.
            By default, the levels are distributed like this:
            - 1-3 Direct verbose output to the user (using Write-Host)
            - 4-6 Output only visible when requesting extra verbosity (using Write-Verbose)
            - 1-9 Debugging information, written using Write-Debug
            The specific level of verbosity preference can be configured using the settings of the message.maximum and message.minimum namespace.
    
            In addition, it is possible to select the level "Warning" which moves the message out of the configurable range:
            The user will always be shown this message, unless he silences the entire thing with -Silent
            
            Possible levels:
            Critical (1), Important / Output (2), Significant (3), VeryVerbose (4), Verbose (5), SomewhatVerbose (6), System (7), Debug (8), InternalComment (9), Warning (666)
            Either one of the strings or its respective number will do as input.
        
        .PARAMETER Silent
            Whether the silent switch was set in the calling function.
            If true, it will write errors, if any, but not write to the screen without explicit override using -Debug or -Verbose.
            If false, it will print a warning if in wrning mode. It will also be willing to write a message to the screen, if the level is within the range configured for that.
        
        .PARAMETER FunctionName
            The name of the calling function.
            Will be automatically set, but can be overridden when necessary.
        
        .PARAMETER ErrorRecord
            If an error record should be noted with the message, add the full record here.
            Especially designed for use with Warning-mode, it can legally be used in either mode.
            The error will be added to the $Error variable and enqued in the dbatools debugging system.
        
        .PARAMETER Warning
            Deprecated, do not use anymore
        
        .PARAMETER Once
            Setting this parameter will cause this function to write the message only once per session.
            The string passed here and the calling function's name are used to create a unique ID, which is then used to register the action in the configuration system.
            Thus will the lockout only be written if called once and not burden the system unduly.
            This lockout will be written as a hidden value, to see it use Get-DbaConfig -Force.
        
        .PARAMETER Target
            If an ErrorRecord was passed, it is possible to add the object on which the error eccoured, in order to simplify debugging / troubleshooting.
        
        .EXAMPLE
            PS C:\> Write-Message -Message 'Connecting to Database1' -Level 4 -Silent $Silent
            
            Writes the message 'Connecting to Database1'. By default, this will be
            - Written to the in-memory message log
            - Written to the logfile
            - Written to the Verbose stream (Write-Verbose)
            - Written to the Debug stream (Write-Debug)
        
        .EXAMPLE
            PS C:\> Write-Message -Message "Connecting to Database 2 failed: $($_.Exception.Message)" -Silent $silent -Warning -ErrorRecord $_ -Target $Database
            
            Writes the message "Connecting to Database 2 failed: $($_.Exception.Message)". By default, this will be
            - Written to the in-memory message log
            - Written to the in-memory error queue
            - Written to the $error variable
            - Written to the logfile
            - Written to the error log files
            - Written to the Warning stream (Write-Warning, not if silent)
            - Written to the Debug stream (Write-Debug)
        
        .NOTES
            Author: Friedrich Weinmann
            Tags: debug
        
        .NOTES
            For Implementers transitioning from previously used cmdlets, rule of thumb:
            - Write-Host:    Level 2
            - Write-Verbose: Level 5
            - Write-Debug:   Level 8
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
    [CmdletBinding(DefaultParameterSetName = 'Level')]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $Message,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Level')]
        [sqlcollective.dbatools.dbaSystem.MessageLevel]
        $Level = "Warning",
        
        [bool]
        $Silent = $Silent,
        
        [string]
        $FunctionName = ((Get-PSCallStack)[0].Command),
        
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Warning')]
        [switch]
        $Warning,
        
        [string]
        $Once,
        
        [object]
        $Target
    )
    
    # Since it's internal, I set it to always silent. Will show up in tests, but not bother the end users with a reminder over something they didn't do.
    Test-DbaDeprecation -DeprecatedOn "1.0.0.0" -Parameter "Warning" -CustomMessage "The parameter -Warning has been deprecated and will be removed on release 1.0.0.0. Please use '-Level Warning' instead." -Silent $true
    
    $timestamp = Get-Date
    $NewMessage = "[$FunctionName][$($timestamp.ToString("HH:mm:ss"))] $Message"
    
    #region Handle Errors
    if ($ErrorRecord)
    {
        $Exception = New-Object System.Exception($Message, $ErrorRecord.Exception)
        $record = New-Object System.Management.Automation.ErrorRecord($Exception, "dbatools_$FunctionName", $ErrorRecord.CategoryInfo.Category, $Target)
        
        if ($Silent) { Write-Error -Message $record -Category $ErrorRecord.CategoryInfo.Category -TargetObject $Target -Exception $Exception -ErrorId "dbatools_$FunctionName" -ErrorAction Continue }
        else { $null = Write-Error -Message $record -Category $ErrorRecord.CategoryInfo.Category -TargetObject $Target -Exception $Exception -ErrorId "dbatools_$FunctionName" -ErrorAction Continue 2>&1 }
        
        [sqlcollective.dbatools.dbaSystem.DebugHost]::WriteErrorEntry($ErrorRecord, $FunctionName, $timestamp, $Message)
    }
    #endregion Handle Errors
    
    $channels = @()
    
    #region Warning Mode
    if ($Warning -or ($Level -like "Warning"))
    {
        if (-not $Silent)
        {
            if ($PSBoundParameters.ContainsKey("Once"))
            {
                $OnceName = "MessageOnce.$FunctionName.$Once"
                
                if (-not (Get-DbaConfigValue -Name $OnceName))
                {
                    Write-Warning $NewMessage
                    Set-DbaConfig -Name $OnceName -Value $True -Hidden -Silent -ErrorAction Ignore
                }
            }
            else
            {
                Write-Warning $NewMessage
            }
            $channels += "Warning"
        }
        Write-Debug $NewMessage
        $channels += "Debug"
    }
    #endregion Warning Mode
    
    #region Message Mode
    else
    {
        $max_info = [sqlcollective.dbatools.dbaSystem.MessageHost]::MaximumInformation
        $max_verbose = [sqlcollective.dbatools.dbaSystem.MessageHost]::MaximumVerbose
        $max_debug = [sqlcollective.dbatools.dbaSystem.MessageHost]::MaximumDebug
        $min_info = [sqlcollective.dbatools.dbaSystem.MessageHost]::MinimumInformation
        $min_verbose = [sqlcollective.dbatools.dbaSystem.MessageHost]::MinimumVerbose
        $min_debug = [sqlcollective.dbatools.dbaSystem.MessageHost]::MinimumDebug
        
        if ((-not $Silent) -and ($max_info -ge $Level) -and ($min_info -le $Level))
        {
            if ($PSBoundParameters.ContainsKey("Once"))
            {
                $OnceName = "MessageOnce.$FunctionName.$Once"
                
                if (-not (Get-DbaConfigValue -Name $OnceName))
                {
                    Write-Host $NewMessage -ForegroundColor (Get-DbaConfigValue -Name 'message.infocolor' -Fallback 'Cyan') -ErrorAction Ignore
                    Set-DbaConfig -Name $OnceName -Value $True -Hidden -Silent -ErrorAction Ignore
                }
            }
            else
            {
                Write-Host $NewMessage -ForegroundColor (Get-DbaConfigValue -Name 'message.infocolor' -Fallback 'Cyan') -ErrorAction Ignore
            }
            $channels += "Information"
        }
        
        if (($max_verbose -ge $Level) -and ($min_verbose -le $Level))
        {
            Write-Verbose $NewMessage
            $channels += "Verbose"
        }
        
        if (($max_debug -ge $Level) -and ($min_debug -le $Level))
        {
            Write-Debug $NewMessage
            $channels += "Debug"
        }
    }
    #endregion Message Mode
    
    $channel_Result = $channels -join ", "
    if ($channel_Result)
    {
        [sqlcollective.dbatools.dbaSystem.DebugHost]::WriteLogEntry($Message, $channel_Result, $timestamp, $FunctionName, $Level)
    }
}

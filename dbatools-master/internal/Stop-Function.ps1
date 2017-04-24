﻿function Stop-Function
{
    <#
        .SYNOPSIS
            Function that interrupts a function.
        
        .DESCRIPTION
            Function that interrupts a function.
            
            This function is a utility function used by other functions to reduce error catching overhead.
            It is designed to allow gracefully terminating a function with a warning by default and also allow opt-in into terminating errors.
            It also allows simple integration into loops.
    
            Note:
            When calling this function with the intent to terminate the calling function in non-silent mode too, you need to add a return below the call.
        
        .PARAMETER Message
            A message to pass along, explaining just what the error was.
        
        .PARAMETER Silent
            Whether the silent switch was set in the calling function.
            If true, it will throw an error.
            If false, it will print a warning.
        
        .PARAMETER Category
            What category does this termination belong to?
            Mandatory so long as no inner exception is passed.
        
        .PARAMETER InnerErrorRecord
            An option to include an inner exception in the error record (and in the exception thrown, if one is thrown).
            Use this, whenever you call Stop-Function in a catch block.
    
            Note:
            Pass the full error record, not just the exception.
        
        .PARAMETER FunctionName
            The name of the function to crash.
            This parameter is very optional, since it automatically selects the name of the calling function.
            The function name is used as part of the errorid.
            That in turn allows easily figuring out, which exception belonged to which function when checking out the $error variable.
        
        .PARAMETER Target
            The object that was processed when the error was thrown.
            For example, if you were trying to process a Database Server object when the processing failed, add the object here.
            This object will be in the error record (which will be written, even in non-silent mode, just won't show it).
            If you specify such an object, it becomes simple to actually figure out, just where things failed at.
        
        .PARAMETER Continue
            This will cause the function to call continue while not running silently.
            Useful when mass-processing items where an error shouldn't break the loop.
        
        .PARAMETER SilentlyContinue
            This will cause the function to call continue while running silently.
            Useful when mass-processing items where an error shouldn't break the loop.
        
        .PARAMETER ContinueLabel
            When specifying a label in combination with "-Continue" or "-SilentlyContinue", this function will call continue with this specified label.
            Helpful when trying to continue on an upper level named loop.
        
        .EXAMPLE
            Stop-Function -Message "Foo failed bar! $($_.Exception.Message)" -Silent $Silent -InnerErrorRecord $_
            return

            Depending on whether $silent is true or false it will:
            - Throw a bloody terminating error. Game over.
            - Write a nice warning about how Foo failed bar, then terminate the function. The return on the next line will then end the calling function.

        .EXAMPLE
            Stop-Function -Message "Foo failed bar!" -Silent $Silent -Category InvalidOperation -Target $foo -Continue

            Depending on whether $silent is true or false it will:
            - Throw a bloody terminating error. Game over.
            - Write a nice warning about how Foo failed bar, then call continue to process the next item in the loop.
            In both cases, the error record added to $error will have the content of $foo added, the better to figure out what went wrong.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(DefaultParameterSetName = 'Plain')]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $Message,
        
        [bool]
        $Silent = $Silent,
        
        [Parameter(ParameterSetName = 'Plain')]
        [Parameter(ParameterSetName = 'Exception')]
        [System.Management.Automation.ErrorCategory]
        $Category = ([System.Management.Automation.ErrorCategory]::NotSpecified),
        
        [Parameter(ParameterSetName = 'Exception')]
        [System.Management.Automation.ErrorRecord]
        $InnerErrorRecord,
        
        [string]
        $FunctionName = ((Get-PSCallStack)[0].Command),
        
        [object]
        $Target,
        
        [switch]
        $Continue,
        
        [switch]
        $SilentlyContinue,
        
        [string]
        $ContinueLabel
    )
    
    $timestamp = Get-Date
    
    $Exception = New-Object System.Exception($Message, $InnerErrorRecord.Exception)
    if ((-not $PSBoundParameters.ContainsKey("Category")) -and ($PSBoundParameters.ContainsKey("InnerErrorRecord")) -and ($InnerErrorRecord.CategoryInfo.Category)) { $Category = $InnerErrorRecord.CategoryInfo.Category }
    $record = New-Object System.Management.Automation.ErrorRecord($Exception, "dbatools_$FunctionName", $Category, $Target)
    
    # Manage Debugging
    Write-Message -Message $Message -Warning -Silent $Silent -FunctionName $FunctionName
    
    #region Silent Mode
    if ($Silent)
    {
        if ($SilentlyContinue)
        {
            Write-Error -Message $record -Category $Category -TargetObject $Target -Exception $Exception -ErrorId "dbatools_$FunctionName" -ErrorAction Continue
            [sqlcollective.dbatools.dbaSystem.DebugHost]::WriteErrorEntry($Record, $FunctionName, $timestamp, $Message)
            if ($ContinueLabel) { continue $ContinueLabel }
            else { Continue }
        }
        
        # Extra insurance that it'll stop
        Set-Variable -Name "__dbatools_interrupt_function_78Q9VPrM6999g6zo24Qn83m09XF56InEn4hFrA8Fwhu5xJrs6r" -Scope 1 -Value $true
		
		# Removed the bottom below because it should be up to the developer to tell the user if its continuing or what
		# It also seems like it's terminating the function as a whole, even if it continues on to the next server
		# Write-Message -Message "Terminating function!" -Level 9 -Silent $Silent -FunctionName $FunctionName
        
        
        throw $record
    }
    #endregion Silent Mode
    
    #region Non-Silent Mode
    else
    {
        # This ensures that the error is stored in the $error variable AND has its Stacktrace (simply adding the record would lack the stacktrace)
        $null = Write-Error -Message $record -Category $Category -TargetObject $Target -Exception $Exception -ErrorId "dbatools_$FunctionName" -ErrorAction Continue 2>&1
        [sqlcollective.dbatools.dbaSystem.DebugHost]::WriteErrorEntry($Record, $FunctionName, $timestamp, $Message)
        
        if ($Continue)
        {
            if ($ContinueLabel) { continue $ContinueLabel }
            else { Continue }
        }
        else
        {
            # Make sure the function knows it should be stopping
            Set-Variable -Name "__dbatools_interrupt_function_78Q9VPrM6999g6zo24Qn83m09XF56InEn4hFrA8Fwhu5xJrs6r" -Scope 1 -Value $true
			
			# Removed the bottom below because it should be up to the developer to tell the user if its continuing or what
			# It also seems like it's terminating the function as a whole, even if it continues on to the next server
			# Write-Message -Message "Terminating function!" -Warning -Silent $Silent -FunctionName $FunctionName
            return
        }
    }
    #endregion Non-Silent Mode
}

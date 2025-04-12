param(
    [Parameter(Mandatory = $true, HelpMessage = "Enter the value for Action. Values can be either start or stop")]
    [ValidateSet("start", "stop")]
    [String]$Action = $(throw "Value for Action is missing"),

    [Parameter(Mandatory = $true, HelpMessage = "Enter the ResourceGroupName.")]
    [String]$ResourceGroupName = $(throw "Value for ResourceGroupName is missing"),

    # [Parameter(Mandatory = $true, HelpMessage = "Enter the day of the week to execute the action. (e.g., Monday, Tuesday, etc.)")]
    # [ValidateSet("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")]
    # [String]$DayOfWeek = $(throw "Value for DayOfWeek is missing"),

    [Parameter(Mandatory = $true, HelpMessage = "Enter one or more days of the week (comma-separated).")]
    [String]$DaysOfWeek = $(throw "Value for DaysOfWeek is missing"),

    [Parameter(Mandatory = $false, HelpMessage = "Enter one or more VM names (comma-separated).")]
    [String]$TargetVMNames
)

[string]$FailureMessage = "Failed to execute the command"
[int]$RetryCount = 3
[int]$TimeoutInSecs = 20
# $RetryFlag = $true
$Attempt = 1

Write-Output "Logging into Azure subscription using Az cmdlets..."
$currentDay = (Get-Date).AddHours(9).DayOfWeek.ToString().ToLower()
Write-Output "Current day is $currentDay"
$DaysOfWeekArray = ($DaysOfWeek -split ',') | ForEach-Object { $_.Trim().ToLower() }

if ($DaysOfWeekArray -contains $currentDay) {
    try {
        # Ensures you do not inherit an AzContext in your runbook
        Disable-AzContextAutosave -Scope Process
        # Connect to Azure with system-assigned managed identity
        Connect-AzAccount -Identity
        # set and store context
        # $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

        Write-Output "Successfully logged into Azure subscription using Az cmdlets..."

        Write-Output "VM action is : $($Action)"

        if ($TargetVMNames) {
            $VMNamesArray = $TargetVMNames -split ','
            $vms = $VMNamesArray | ForEach-Object {
                Get-AzVM -Name $_ -ResourceGroupName $ResourceGroupName
            }
        } else {
            $vms = Get-AzVM -ResourceGroupName $ResourceGroupName
        }

        foreach ($VMName in $vms) {
            if ($Action.Trim().ToLower() -eq "stop") {
                Write-Output "Stopping the VM : $($VMName) in Resource Group $($ResourceGroupName)"

                $Status = Stop-AzVM -Name $VMName.name -ResourceGroupName $ResourceGroupName -Force

                if ($null -eq $Status) {
                    Write-Output "Error occurred while stopping the Virtual Machine $($VMName) in Resource Group $($ResourceGroupName)"
                } else {
                    Write-Output "Successfully stopped the VM $VMName in Resource Group $($ResourceGroupName)"
                }
            } elseif ($Action.Trim().ToLower() -eq "start") {
                Write-Output "Starting the VM : $($VMName) in Resource Group $($ResourceGroupName)"

                $Status = Start-AzVM -Name $VMName.name -ResourceGroupName $ResourceGroupName

                if ($null -eq $Status) {
                    Write-Output "Error occurred while starting the Virtual Machine $($VMName) in Resource Group $($ResourceGroupName)"
                } else {
                    Write-Output "Successfully started the VM $($VMName) in Resource Group $($ResourceGroupName)"
                }
            }
        }

    } catch {
        if ($Attempt -gt $RetryCount) {
            Write-Output "$FailureMessage! Total retry attempts: $RetryCount"

            Write-Output "[Error Message] $($_.exception.message) `n"

            # $RetryFlag = $false
        } else {
            Write-Output "[$Attempt/$RetryCount] $FailureMessage. Retrying in $TimeoutInSecs seconds..."

            Start-Sleep -Seconds $TimeoutInSecs

            $Attempt = $Attempt + 1
        }
    }
} else {
    Write-Output "Today is $currentDay. The action will not be executed as it is not one of the specified days: $DaysOfWeek."
}
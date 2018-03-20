# Get the input request
$in = Get-Content $req -Raw
$json = ConvertFrom-Json $in

write-output $in

if ($json.status -eq "Resolved") {
   Write-output "Status is " $json.status
}
else {
    Write-Output $json.status
    Write-Output $json.context.resourceGroupName
    Write-Output $json.context.resourceName
    
    # Application ID for our Azure Security Principal that we created and provided via Function Application Settings
    $username = $env:AzureAutomationAppID

    # Password for connection to Azure via Function Application Settings
    $pw = $env:AzureAutomationPWD
    $key = Get-Content 'D:\home\site\wwwroot\reboot\4sessions.key'
    $password = $pw | ConvertTo-SecureString -key $key
    $credentials = New-Object System.Management.Automation.PSCredential $username,$password
    $AzureRMAccount = Add-AzureRmAccount -Credential $credentials -ServicePrincipal -TenantId $env:AzureAutomationTenantID
    If ($AzureRMAccount) { 
        Restart-AzureRmWebApp -ResourceGroupName $json.context.resourceGroupName -Name $json.context.resourceName
        write-output "==== WebApp restarted ====" $json.context.resourceName
    }
}
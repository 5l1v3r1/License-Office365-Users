# +---------------------------------------------------------------------------
# | File : license-office365-users.ps1                                          
# | Version : 0.2                                          
# | Description : This script will license users in Office 365 from a .CSV file. Users who are already licensed will not be affected and will be written to a log.txt file.
# | Usage : .\license-office365-users.ps1
# +----------------------------------------------------------------------------
# | Maintenance History                                            
# | -------------------                                            
# | Name            Date         Version  Description        
# | ----------------------------------------------------------------------------------
# | Mikail Tunc     03/08/2015   0.1      Initial version
# | Mikail Tunc     04/08/2015   0.2      Added error checking. If user is already licensed, they are written to a log file where the admin can decide what to do. Added progress bar.
# +-------------------------------------------------------------------------------

Write-Host "Please ensure users are in Office 365 before running this script - perhaps a later version will check this for you" -ForegroundColor Green
Write-Host "Ensure the CSV file has the header 'userPrincipalName'. New line for every user." -ForegroundColor Green
Write-Host "Also note that if you have JUST added a user, it may have not sync'd across yet. Go grab a KitKat (or force a sync on the 365 DirSync server)" -ForegroundColor Green
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# | Prompt for Office 365 credentials and connect to the service. Fail if cannot connect. 
$exchangeOnlineUserName = Read-Host 'What is your Office 365 Username?'
$exchangeOnlinePassword = Read-Host 'What is your Office 365 Password?' -AsSecureString
$exchangeOnlineCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $exchangeOnlineUserName,$exchangeOnlinePassword
Connect-MsolService -Credential $exchangeOnlineCred
If($? -eq $False)
{
Write-Host "Error while connecting to the Office 365 provisioning web service API.  Quiting..." -BackgroundColor Red
Exit
}
# | ----------------------------------------------------------------------------------

# | Prompt for CSV location. Default if blank.
$csvPath = Read-Host 'Path to CSV file. Please remember to double quote if there is a space in the directory or file name - leave blank for default which is C:\csv\users.csv'
If([string]::IsNullOrWhiteSpace($csvPath))
{
$csvPath = "C:\csv\users.csv"
}
# | ----------------------------------------------------------------------------------

# | Import CSV, loop through users and license them
$users = Import-Csv -Path $csvPath      
$counter = 0    
foreach ($user in $users)            
{   
    $UPN = $user.userPrincipalName
    If(Get-MsolUser -UserPrincipalName $UPN | Where-Object { $_.isLicensed -eq $false })
    {
    $counter++
    Set-MsolUser -UserPrincipalName "$UPN" -UsageLocation GB
    Set-MsolUserLicense -UserPrincipalName "$UPN" -AddLicenses TENANTNAME:LICENSE
    Write-Progress -Activity "Processing $UPN" -CurrentOperation $UPN -PercentComplete (($counter / $users.count) * 100)
    }
    Else
    {
    $UPN + "`n" | Out-File -Append $csvPath\log.txt
    }
}
Write-Host "COMPLETE!!! Note that it can take a few minutes before the changes are active on the 365 portal" -ForegroundColor Green
Write-Host "Note that any users who already have licenses assigned to them have not been affected by this script and have been added to log.txt" -ForegroundColor Yellow
# | ----------------------------------------------------------------------------------
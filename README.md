# License Office365 Users - PowerShell Script

You can use this script to bulk-license Office365 users.

## Usage

1. Create a .CSV file with the header 'userPrincipalName'
2. In the script change the value of the 'Set-MsolUserLicense' command to suite your environment - I plan on automating this bit in the next iteration
3. Also define the .csv and log location in the script in the section titled 'variables'

To check your account license types simply use the command Get-MsolAccountSku.

## History

0.1 03/08/2015: Initial version

0.2 04/08/2015: Added error checking. If user is already licensed, they are written to a log file where the admin can decide what to do. Added progress bar.
0.3 29/09/2015: No longer prompt for CSV location. Instead define CSV and log location in the script before running

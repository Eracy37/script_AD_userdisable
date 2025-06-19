## script_AD_userdisable
script to move desactivated users to another OU and remove the user's groups + create a file before the process to keep track of them

### Use 
Modifiy param :
```bash
$Target = 'OU=USERS,OU=XXX,DC=XXX,DC=local'
$TargetDisabledOU = 'OU=XXX,OU=USERS,OU=XXX,DC=XXX,DC=local'

$ExportCSV = "C:\PATH\Disabled_Users-$($Date).csv"
```

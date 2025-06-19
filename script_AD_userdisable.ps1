#===============================================================================
# Script Name   : script_AD_userdisable.ps1
# Author        : GUERRY Cynthia (Eracy37)
# Version       : 1.0.0
# Last Modifed  : 16/04/2025
# Description   : Script to move desactivated users to another OU and remove the user's groups + create a file before the process to keep track of them
#===============================================================================

$results = @()

$Date = Get-Date -Format yyyyMMdd-HHmm

# Target to modify
$Target = 'OU=USERS,OU=XXX,DC=XXX,DC=local'
$TargetDisabledOU = 'OU=XXX,OU=USERS,OU=XXX,DC=XXX,DC=local'

$ExportCSV = "C:\PATH\Disabled_Users-$($Date).csv"
 
# Export CSV of AD User Groups

$disabledUsers = Search-ADAccount -SearchBase $Target -AccountDisabled -UsersOnly

Foreach ($user in $disabledUsers) {
    $UserDetails = Get-ADUser -Identity $user.SamAccountName -Property MemberOf
    $GroupName = $UserDetails.MemberOf | ForEach-Object {
        (Get-ADGroup $_).Name
    }
}

$results += [PSCustomObject]@{
    UserName = $user.SamAccountName
    Location = $user.DistinguishedName
    Groups = ($GroupName -join ", ")
}

$results | Export-Csv -Path $ExportCSV -NoTypeInformation -Delimiter "," -ErrorAction Stop

# Remove users from groups

$MemberUsers = Get-ADUser -Filter {Enabled -eq $false} -SearchBase $Target -Properties MemberOf

foreach ($Mbuser in $MemberUsers) {
    $Account = $Mbuser.SamAccountName
    $groups = $Mbuser.MemberOf
    foreach ($group in $groups) {
        $groupSearchName = (Get-ADGroup $group).Name
        if ($groupSearchName -ne "Domain Users") {
            Remove-ADGroupMember -Identity $groupSearchName -Members $Account -Confirm:$false
            Write-Host "User $Account removed from group $groupSearchName"
        }
    }

    # Move Users to Disabled OU
    try {
        Move-ADObject -Identity $Mbuser.DistinguishedName -TargetPath $TargetDisabledOU
    }
    catch {
        Write-Host "User $Account is protected, cannot be moved"
    }
}

Write-Host "Operation completed"
Write-Host "Report location $ExportCSV"

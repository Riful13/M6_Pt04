function Get-ListUsers {
    Get-LocalUser | Select-Object Name, Enabled, LastLogon
}

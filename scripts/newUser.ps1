# CrearUsuario.ps1
param (
    [string]$Username,
    [string]$Password
)

New-LocalUser -Name $Username -Password (ConvertTo-SecureString $Password -AsPlainText -Force) -FullName $Username -Description "Usuario creado por script"
Add-LocalGroupMember -Group "Users" -Member $Username
Write-Host "Usuario $Username creado exitosamente."
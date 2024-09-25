# CambiarContrasena.ps1
param (
    [string]$Username,
    [string]$NewPassword
)

$User = Get-LocalUser -Name $Username
if ($User) {
    $User | Set-LocalUser -Password (ConvertTo-SecureString $NewPassword -AsPlainText -Force)
    Write-Host "Contraseña de $Username cambiada exitosamente."
} else {
    Write-Host "Usuario $Username no encontrado."
}
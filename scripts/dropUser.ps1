function Drop-User {
    param (
        [string]$Username
    )

    $User = Get-LocalUser -Name $Username
    if ($User) {
        Remove-LocalUser -Name $Username
        Write-Host "Usuario $Username eliminado exitosamente."
    } else {
        Write-Host "Usuario $Username no encontrado."
    }
}
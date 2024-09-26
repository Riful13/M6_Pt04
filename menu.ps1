# LIST USERS
function Get-ListUsers {
    Get-LocalUser | Select-Object Name, Enabled, LastLogon
}

# CAMBIO DE PASSWORD
function Cambiar-Contrasena {
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
}

# DROP USER
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

# NEW USER
function CrearUsuario {
    param (
        [string]$Username,
        [string]$Password
    )

    New-LocalUser -Name $Username -Password (ConvertTo-SecureString $Password -AsPlainText -Force) -FullName $Username -Description "Usuario creado por script"
    Add-LocalGroupMember -Group "Users" -Member $Username
    Write-Host "Usuario $Username creado exitosamente."
}

function Show-Menu {
    param (
        [string]$Title = 'MENÚ PRINCIPAL'
    )

    Write-Host "====================="
    Write-Host " $Title"
    Write-Host "====================="
    Write-Host "1. Listar Usuarios"
    Write-Host "2. Cambiar Contraseña"
    Write-Host "3. Eliminar Usuario"
    Write-Host "4. Crear Usuario"
    Write-Host "====================="
    Write-Host "0. Salir"
    Write-Host "====================="
}

function Process-Option {
    param (
        [int]$Option
    )

    switch ($Option) {
        1 { Get-ListUsers }
        2 { 
            $username = Read-Host "Introduce el nombre de usuario"
            $newPassword = Read-Host "Introduce la nueva contraseña"
            Cambiar-Contrasena -Username $username -NewPassword $newPassword
        }
        3 { 
            $username = Read-Host "Introduce el nombre de usuario"
            Drop-User -Username $username
        }
        4 { 
            $username = Read-Host "Introduce el nombre de usuario"
            $password = Read-Host "Introduce la contraseña"
            CrearUsuario -Username $username -Password $password
        }
        0 { Write-Host "Saliendo del programa..."; exit }
        default { Write-Host "Opción no válida. Inténtalo de nuevo." }
    }
}

function Validate-Selection {
    param (
        [string]$Selection
    )

    if ($Selection -match '^\d+$') {
        return [int]$Selection
    } else {
        Write-Host "Entrada no válida. Por favor, introduce un número."
        return $null
    }
}

do {
    Show-Menu
    $selection = Read-Host "Selecciona una opción"
    $validatedSelection = Validate-Selection -Selection $selection
    if ($null -ne $validatedSelection) {
        Process-Option -Option $validatedSelection
    }
} while ($validatedSelection -ne 0)

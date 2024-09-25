# Archivo: /c:/Archivos Personales/aisx/m6/pureba.ps1

function Show-Menu {
    param (
        [string]$Title = 'MENÚ PRINCIPAL'
    )

    Write-Host "====================="
    Write-Host " $Title"
    Write-Host "====================="
    Write-Host "1. Opción 1"
    Write-Host "2. Opción 2"
    Write-Host "3. Opción 3"
    Write-Host "4. Opción 4"
    Write-Host "====================="
    Write-Host "0. Salir"
    Write-Host "====================="
}

function Process-Option {
    param (
        [int]$Option
    )

    switch ($Option) {
        1 { Write-Host "Has seleccionado la Opción 1" }
        2 { Write-Host "Has seleccionado la Opción 2" }
        3 { Write-Host "Has seleccionado la Opción 3" }
        4 { Write-Host "Has seleccionado la Opción 4" }
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
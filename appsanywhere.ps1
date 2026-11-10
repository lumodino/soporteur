$appsanywhere = (get-package "Appsanywhere").version

# comprobar versión
if ($appsanywhere -ne "2.7.0" -and $null -ne $appsanywhere) {
    # VERSION INCORRECTA
    Write-warning "Appsanywhere no está actualizado. Finalizando procesos..."
    get-process "AppsAnywhere" | Stop-Process -Force -Confirm:$false
    Get-Service AppsAnywhereService | Stop-Service -Force -Confirm:$false

    Write-Warning "Desinstalando..."
    Get-Package "AppsAnywhere" | Uninstall-Package -Force -Confirm:$false
}

if ($null -eq (get-package "Appsanywhere")) {
    # instalando appsanywere
    Write-warning "Appsanywhere no está instalado. Descargando..."
    $appsanywhere_url = "https://files.appsanywhere.com/clients/appsanywhere/win/2.7.0/apps-anywhere-installer-x64.msi"
    #Invoke-WebRequest -Uri $appsanywhere_url -OutFile $env:TEMP\apps-anywhere-installer-x64.msi
    Start-BitsTransfer $appsanywhere_url $env:temp -Description "Descargando instalador de appsanywhere en %temp%"
    Start-Process -filepath msiexec.exe -argumentlist "/i $env:TEMP\apps-anywhere-installer-x64.msi /qn" -Wait -Verb runas
    Remove-Item $env:temp\apps-anywhere-installer-x64.msi -force -Confirm:$false

}

Write-Warning "Finalizando cloudpaging"
get-service streamingcore | Stop-Service -Force -confirm:$false
get-process JukeboxPlayer | Stop-Process -Force -Confirm:$false

Write-Warning "Instalando Cloudpaging"
$cloudpaging_url = "https://files.appsanywhere.com/clients/cloudpaging/9.6.4.4271/cloudpaging-player-setup-x64-ARM64.msi"
#Invoke-WebRequest -Uri $cloudpaging_url -OutFile $env:TEMP\cloudpaging-player-setup-x64-ARM64.msi
Start-BitsTransfer $cloudpaging_url $env:temp -Description "Descargando instalador de cloudpaging en %temp%"

if($null -eq (get-package "Cloudpaging Player")){
    Start-Process -filepath msiexec.exe -argumentlist "/qn /i $env:TEMP\cloudpaging-player-setup-x64-ARM64.msi ET_AUTO_ELEVATION=1" -Wait -Verb runas
}else{
    Start-Process -filepath msiexec.exe -argumentlist "/qn /i $env:TEMP\cloudpaging-player-setup-x64-ARM64.msi REINSTALL=ALL REINSTALLMODE=vamus" -Wait -Verb runas
}
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Numecent\StreamingCore\Settings\AppEvent" /v AllowLocalSystem /t REG_DWORD /d "1" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Numecent\StreamingCore\Settings\Driver" /v PhysicalLayerMode /t REG_DWORD /d "1" /f
Remove-Item $env:temp\cloudpaging-player-setup-x64-ARM64.msi -force -Confirm:$false


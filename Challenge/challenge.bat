@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Verifica que se hayan pasado todos los argumentos necesarios
if "%~8"=="" (
    echo Usage: challenge.bat "Nombre_VM" "Tipo_Sistema" "Num_CPUs" "Memoria_RAM_MB" "VRAM_MB" "Tamano_Disco_MB" "Nombre_Controlador_SATA" "Nombre_Controlador_IDE"
    echo Ejemplo: challenge.bat "MiLinuxVM" "Linux_64" 2 2048 128 20000 "SATA_Controller" "IDE_Controller"
    exit /b 1
)

:: Posiciono en la carpeta donde tengo VBoxManage
cd "\Program Files\Oracle\VirtualBox"
:: Asignación de argumentos a variables
set VM_NAME=%1
set OS_TYPE=%2
set NUM_CPUS=%3
set MEM_RAM=%4
set VRAM=%5
set DISK_SIZE=%6
set SATA_CTRL=%7
set IDE_CTRL=%8

:: Crea la máquina virtual
echo Creando maquina virtual "%VM_NAME%"...
VBoxManage createvm --name "%VM_NAME%" --ostype "%OS_TYPE%" --register

:: Configura la cantidad de CPUs
echo Configurando CPUs a %NUM_CPUS%...
VBoxManage modifyvm "%VM_NAME%" --cpus %NUM_CPUS%

:: Configura la memoria RAM y VRAM
echo Configurando RAM a %MEM_RAM% MB y VRAM a %VRAM% MB...
VBoxManage modifyvm "%VM_NAME%" --memory %MEM_RAM% --vram %VRAM%

:: Crea un disco duro virtual y lo asocia
set "DISK_PATH=%~dp0%VM_NAME%.vdi"
echo Creando disco virtual de %DISK_SIZE% MB en "%DISK_PATH%"...
VBoxManage createmedium disk --filename "%DISK_PATH%" --size %DISK_SIZE% --format VDI

:: Crea y configura el controlador SATA, luego asocia el disco duro virtual a él
echo Creando y configurando el controlador SATA %SATA_CTRL% ...
VBoxManage storagectl %VM_NAME% --name %SATA_CTRL% --add sata --controller IntelAhci
VBoxManage storageattach %VM_NAME% --storagectl %SATA_CTRL% --port 0 --device 0 --type hdd --medium %DISK_PATH%

:: Crea y configura el controlador IDE para CD/DVD
echo Creando y configurando el controlador IDE "%IDE_CTRL%"...
VBoxManage storagectl "%VM_NAME%" --name "%IDE_CTRL%" --add ide
VBoxManage storageattach "%VM_NAME%" --storagectl "%IDE_CTRL%" --port 0 --device 0 --type dvddrive --medium emptydrive

:: Muestra la configuración completa de la máquina virtual
echo.
echo Configuracion de la maquina virtual "%VM_NAME%":
VBoxManage showvminfo "%VM_NAME%"

echo Configuración de la máquina virtual "%VM_NAME%":
echo -------------------------------------------
echo Nombre de la VM: %VM_NAME%
echo Tipo de Sistema Operativo:
VBoxManage showvminfo "%VM_NAME%" | findstr /C:"Guest OS"
echo CPUs:
VBoxManage showvminfo "%VM_NAME%" | findstr /C:"Number of CPUs"
echo Memoria RAM:
VBoxManage showvminfo "%VM_NAME%" | findstr /C:"Memory size"
echo Memoria de Video:
VBoxManage showvminfo "%VM_NAME%" | findstr /C:"VRAM size"
echo Controlador SATA:
VBoxManage showvminfo "%VM_NAME%" | findstr /C:"Storage Controller Name (0)"
echo Disco Duro:
VBoxManage showvminfo "%VM_NAME%" | findstr /C:"SATA (0, 0)"

echo.
echo La maquina virtual ha sido creada y configurada con exito.
endlocal
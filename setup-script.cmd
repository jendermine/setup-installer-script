@echo off

::Checking for administrator rights using fsutil
::which just queries the volume here %systemdrive% for a 'dirty bit' for corrupted volume 
::WITHOUT TOUCHING ANY FILES/REGISTERY ANYTHING at all

fsutil dirty query %systemdrive% >nul
IF %ERRORLEVEL% GTR 0 goto NO_ADMIN_ERROR

::Checking for spaces in the folders in which this script is located
::Since, it was causing issues with Mounting and Ejecting ISOs

cd /d "%~dp0"
IF NOT "%cd%"=="%cd: =%" goto SPACES_ERROR

echo Welcome to a Very simple and effortless installation and uninstallation of
echo Both Age Of Empires2 and Conquerors Expansion Pack
echo =====================================================
echo To INSTALL type y (no capitals)
echo To UNINSTALL type n (no capitals)
echo =====================================================

:INVALID_INPUT_ERROR

set /p inp=

if %inp%==y goto label1
if %inp%==n goto label2
goto INVALID_INPUT_ERROR

:label1

cd>%temp%\path.txt
set /p room=< %temp%\path.txt
del /q %temp%\path.txt
::Mounting the ISOs

powershell Mount-DiskImage -ImagePath "%room%\Age` of` Empires` 2.iso">NUL
powershell Mount-DiskImage -ImagePath "%room%\Age` of` Empires` 2` -` The` Conquerors` Expansion.iso">NUL


::Getting the ISOs' Drive Letters for their path
::By using a temporary txt files on %temp% directory
::which will get deleted ASAP

powershell "(Get-DiskImage -DevicePath \\.\CDROM1 | Get-Volume).DriveLetter" > %temp%\aoe2.txt
powershell "(Get-DiskImage -DevicePath \\.\CDROM2 | Get-Volume).DriveLetter" > %temp%\aoe2_x1.txt

set /p var1=< %temp%\aoe2.txt
set /p var2=< %temp%\aoe2_x1.txt

del /q %temp%\aoe2.txt
del /q %temp%\aoe2_x1.txt

::checking if already installed or not

if not exist "C:\Program Files (x86)\Microsoft Games\Age of Empires II\UNINSTAL.EXE" goto jump11
if not exist "C:\Program Files (x86)\Microsoft Games\Age of Empires II\UNINSTALX.EXE" goto jump12
goto jump13

:jump11

cd /d %var1%:\
AOESETUP.EXE
timeout 60

:jump12

cd /d %var2%:\
AOCSETUP.EXE
timeout 45

:jump13

::Some workarounds easily managed by the script no need to worry about

cd /d "%room%\AoC 1.0c\"
"AoC 1.0c Patch.exe"
copy "AoC 1.0c Patch No-CD Crack\age2_x1.exe" "C:\Program Files (x86)\Microsoft Games\Age of Empires II\age2_x1\">NUL

::Game folder directly opened infront of you

explorer "C:\Program Files (x86)\Microsoft Games\Age of Empires II\age2_x1\"

echo INSTALLATION FINISHED
pause
goto :EOF

:label2

cd>%temp%\path.txt
set /p room=< %temp%\path.txt
del /q %temp%\path.txt

cd /d "C:\Program Files (x86)\Microsoft Games\Age of Empires II\" 2>nul
if %ERRORLEVEL% GTR 0 goto jump23 

::checking if already uninstalled or not

if exist UNINSTALX.EXE goto jump21
if exist UNINSTAL.EXE goto jump22
goto jump23

:jump21
UNINSTALX.EXE

:jump22
UNINSTAL.EXE

:jump23

::Cleanup of unwanted residue files

cd /
if not exist "C:\Program Files (x86)\Microsoft Games" goto jump24
rmdir /s /q "C:\Program Files (x86)\Microsoft Games"

:jump24

::Ejecting the ISOs

powershell DisMount-DiskImage -ImagePath "%room%\Age` of` Empires` 2.iso">NUL
powershell DisMount-DiskImage -ImagePath "%room%\Age` of` Empires` 2` -` The` Conquerors` Expansion.iso">NUL

::Cleanup of temporary files

rmdir /s /q %temp%
if exist %temp% goto jump25
md %temp%

:jump25
echo UNINSTALLATION FINISHED
pause
goto :EOF

:SPACES_ERROR

echo Current directory contains spaces in its path.
echo Please move or rename the directory to one not containing spaces.
echo .
pause
goto :EOF

:NO_ADMIN_ERROR

echo =====================================================
echo This script needs to be executed as an administrator.
echo =====================================================
echo .
pause
goto :EOF
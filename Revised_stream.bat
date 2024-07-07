@echo off
setlocal enabledelayedexpansion

:: Check if youtube-dl is installed
youtube-dl --version > nul 2>&1
if %errorlevel% neq 0 (
    :: Check if choco is installed
    choco -v > nul 2>&1
    if %errorlevel% neq 0 (
        :: Install choco
        echo Installing Chocolatey...
        @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    )
    :: Install youtube-dl using choco
    echo Installing youtube-dl...
    choco install youtube-dl -y > nul
)

:: Prompt the user for the output directory using a popup dialog box
set "VBS_SCRIPT=%temp%\get_folder.vbs"
>"%VBS_SCRIPT%" echo set shell = CreateObject("Shell.Application") : set folder = shell.BrowseForFolder(0, "Select Output Directory", 512) : if folder is nothing then wscript.echo "" else wscript.echo folder.self.path
for /f "delims=" %%d in ('cscript /nologo "%VBS_SCRIPT%"') do set "output_dir=%%d"
del "%VBS_SCRIPT%"

if "%output_dir%"=="" (
    echo No directory selected. Exiting script.
    exit /b 1
)

:: Ensure the output directory exists
if not exist "%output_dir%" (
    echo Creating output directory...
    mkdir "%output_dir%"
)

set "file_count=0"

:loop
set /p url=Enter the URL of the video: 
if "%url%"=="" (
    echo No URL entered. Exiting script.
    exit /b 1
)

:: Basic URL validation (optional)
echo %url% | findstr /i "http://" "https://" >nul
if %errorlevel% neq 0 (
    echo Invalid URL. Please enter a valid URL.
    goto loop
)

set /p file_name=Enter a custom name for the output file (press Enter to use default): 

if "%file_name%"=="" (
    set "output_file=%output_dir%\file_%file_count%.mp4"
) else (
    set "output_file=%output_dir%\%file_name%.mp4"
)

:: Ensure unique file names
:unique_check
if exist "%output_file%" (
    set /a file_count+=1
    if "%file_name%"=="" (
        set "output_file=%output_dir%\file_%file_count%.mp4"
    ) else (
        set "output_file=%output_dir%\%file_name%_%file_count%.mp4"
    )
    goto unique_check
)

:: Download video using youtube-dl
youtube-dl -o "%output_file%" "%url%"

echo Video extraction complete. Output file: %output_file%

set /p continue=Do you want to extract another video? (Y/N): 
if /i "%continue%"=="Y" (
    goto loop
) else (
    echo All extractions complete. The following files were extracted:
    dir /b "%output_dir%"
    echo Exiting script.
    pause
)

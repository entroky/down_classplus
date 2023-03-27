@echo off
where ffmpeg >nul 2>&1
if %errorlevel% == 0 (
    echo ffmpeg is already installed.
) else (
    echo ffmpeg is not installed.
    rem Check if Chocolatey is installed
    where choco >nul 2>&1
    if %errorlevel% == 0 (
        echo Chocolatey is installed. Installing ffmpeg using Chocolatey...
        choco install ffmpeg -y --source="'https://community.chocolatey.org/api/v2/'"
        echo ffmpeg has been installed.
    ) else (
        echo Chocolatey is not installed. Installing Chocolatey and ffmpeg...
        rem Install Chocolatey
        Set "PS_COMMAND=\"Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex\""
        powershell -NoProfile -ExecutionPolicy Bypass -Command %PS_COMMAND%
        echo Chocolatey has been installed. Installing ffmpeg...
        choco install ffmpeg -y --source="'https://community.chocolatey.org/api/v2/'"
        echo ffmpeg has been installed.
    )
) 
:: Prompt the user for the output directory using a popup dialog box
set "VBS_SCRIPT=%temp%\get_folder.vbs"
>"%VBS_SCRIPT%" echo set shell = CreateObject("Shell.Application") : set folder = shell.BrowseForFolder(0, "Select Output Directory", 512) : if folder is nothing then wscript.echo "" else wscript.echo folder.self.path
for /f "delims=" %%d in ('cscript /nologo "%VBS_SCRIPT%"') do set "output_dir=%%d"

set "file_count=0"
:loop
set /p url=Enter the URL of the video: 
set /p file_name=Enter a custom name for the output file (press Enter to use default): 

set "output_file=%output_dir%\file_%file_count%.mp4"

if not "%file_name%"=="" (
    set "output_file=%output_dir%\%file_name%.mp4"
)

if exist "%output_file%" (
    set /a file_count+=1
    set "output_file=%output_dir%\file_%file_count%.mp4"
)

ffmpeg -i "%url%" -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 "%output_file%"

echo Video extraction complete. Output file: %output_file%

set /p continue=Do you want to extract another video? (Y/N): 
if /i "%continue%"=="Y" goto loop

echo All extractions complete. The following files were extracted:
dir /b "%output_dir%"

echo Exiting script.
pause

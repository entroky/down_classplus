@echo off
rem Check if ffmpeg is installed
ffmpeg -version > nul 2>&1
if %errorlevel% == 0 (
    echo ffmpeg is already installed.
) else (
    rem Check if choco is installed
    choco -v > nul 2>&1
    if %errorlevel% == 0 (
        echo choco is already installed. Installing ffmpeg using choco...
        choco install ffmpeg
    ) else (
        rem Install choco
        echo choco is not installed. Installing choco...
        @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

        rem Install ffmpeg using choco
        echo Installing ffmpeg using choco...
        choco install ffmpeg
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

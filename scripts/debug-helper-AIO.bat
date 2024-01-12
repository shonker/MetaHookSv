@echo off

:: Check if SolutionDir is already set and non-empty
if not defined SolutionDir (
    :: Only set SolutionDir if it's not already set
    SET "SolutionDir=%~dp0.."
)

:: Ensure the path ends with a backslash
if not "%SolutionDir:~-1%"=="\" SET "SolutionDir=%SolutionDir%\"

if not "%GameDir%"=="" (
    if exist "%GameDir%\" goto start_copy

    echo Error: The GameDir "%GameDir%" is not existing !!!
    pause
    exit
)

for /f "delims=" %%a in ('"%SolutionDir%\tools\SteamAppsLocation" %GameAppId% InstallDir') do set OutputString=%%a

if %ERRORLEVEL% equ 0 (
    set "GameDir=%OutputString%"
    goto start_copy
)

echo Error: Failed to locate GameInstallDir of %FullGameName%, please make sure Steam is running and you have %FullGameName% installed correctly.
pause
exit

:start_copy

echo -----------------------------------------------------
echo Writing MSVC Properties...

cd /d "%SolutionDir%tools\"

copy global_template.props global.props /y

call powershell -Command "(gc global.props) -replace '<MetaHookLaunchName>.*</MetaHookLaunchName>', '<MetaHookLaunchName>%LauncherExe%</MetaHookLaunchName>' | Out-File global.props"
call powershell -Command "(gc global.props) -replace '<MetaHookLaunchCommnand>.*</MetaHookLaunchCommnand>', '<MetaHookLaunchCommnand>-game %LauncherMod%</MetaHookLaunchCommnand>' | Out-File global.props"
call powershell -Command "(gc global.props) -replace '<MetaHookGameDirectory>.*</MetaHookGameDirectory>', '<MetaHookGameDirectory>%GameDir%\</MetaHookGameDirectory>' | Out-File global.props"
call powershell -Command "(gc global.props) -replace '<MetaHookModName>.*</MetaHookModName>', '<MetaHookModName>%LauncherMod%</MetaHookModName>' | Out-File global.props"

echo -----------------------------------------------------
echo Done

@echo off

tasklist | find /i "devenv.exe"

if "%errorlevel%"=="1" (goto ok1) else (goto ok2)

:ok1
@echo You can open MetaHook.sln with Visual Studio IDE now
pause
exit

:ok2
@echo Please restart Visual Studio IDE to apply changes to the msvc properties
pause
exit

:fail
@echo Failed to locate GameInstallDir of %FullGameName%, please make sure Steam is running and you have %FullGameName% installed correctly.
pause
exit
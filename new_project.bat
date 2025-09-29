@echo off
setlocal enabledelayedexpansion
:: new_project.bat - 支援靈活的項目結構
:: Usage: new_project.bat [TemplateType] [ProjectPath]
:: 
:: Note 模板範例:
::   new_project.bat Note "LinearAlgebra/Note"
::   -> 創建 input/LinearAlgebra/Note/ 資料夾，包含 master.tex 和 lectures/
::
:: HW 模板範例:
::   new_project.bat HW "LinearAlgebra/A/B/C"
::   -> 創建 input/LinearAlgebra/A/B/C.tex 文件


:: 如果參數為空：提供提示
if "%2"=="" (
    echo Usage: new_project.bat [TemplateType] [ProjectPath]
    echo.
    echo Examples:
    echo   new_project.bat Note "LinearAlgebra/Note"
    echo     ^-^> Creates folder: input/LinearAlgebra/Note/ with master.tex
    echo.
    echo   new_project.bat HW "LinearAlgebra/A/B/C"
    echo     ^-^> Creates file: input/LinearAlgebra/A/B/C.tex
    echo.
    call :echo_available_template
    goto :eof
)

:: 設定變數
set "PROJECT_PATH=%~2"
set "TEMPLATE_TYPE=%1"

set "WORKSPACE_ROOT=%~dp0"

echo Creating project: %PROJECT_PATH%
echo Template: %TEMPLATE_TYPE%
echo.

if "%TEMPLATE_TYPE%"=="Note" (
    call :create_note_project
    goto :eof
)
if "%TEMPLATE_TYPE%"=="HW" (
    call :create_hw_project
    goto :eof
)
echo Error: Unsupported template type: %TEMPLATE_TYPE%
call :echo_available_template
goto :eof



:: Note 模板：創建資料夾結構
:create_note_project
set "INPUT_DIR=%WORKSPACE_ROOT%\input\%PROJECT_PATH%"

echo Note project details:
echo Input folder: %INPUT_DIR%

mkdir "%INPUT_DIR%" 2>nul

:: Copy template files (only core files, not shared)
echo Copying template files...
xcopy "%WORKSPACE_ROOT%\templates\Note\" "%INPUT_DIR%" /E /I


echo Note project created successfully!
echo.
echo Project contents:
dir /b "%INPUT_DIR%"
echo.
echo Next steps:
echo 1. Edit files in: input\%PROJECT_PATH%\lectures\
echo 2. Create lec_3.tex, lec_4.tex, etc. as needed  
echo 3. Compile with: compile.bat "%PROJECT_PATH%"
goto :eof




:: HW 模板：創建單個文件
:create_hw_project
for /f "delims=" %%i in ('powershell -command "Split-Path '%PROJECT_PATH%' -Parent"') do set "HW_DIR=%%i"
for /f "delims=" %%i in ('powershell -command "Split-Path '%PROJECT_PATH%' -Leaf"') do set "HW_NAME=%%i"
if "%HW_DIR%"=="" set "HW_DIR=."

set "INPUT_DIR=%WORKSPACE_ROOT%\input\%HW_DIR%"
set "HW_FILE=%INPUT_DIR%\%HW_NAME%.tex"

echo HW project details:
echo Input file: %HW_FILE%
echo.

mkdir "%INPUT_DIR%" 2>nul
:: Copy and rename HW template file
if exist "%WORKSPACE_ROOT%\templates\%TEMPLATE_TYPE%\master.tex" (
    if exist "%HW_FILE%" (
        echo File already exists: %HW_NAME%.tex
        set /p "overwrite=Overwrite existing file? (y/n): "
        if /i "!overwrite!"=="y" (
            copy "%WORKSPACE_ROOT%\templates\%TEMPLATE_TYPE%\master.tex" "%HW_FILE%"
            echo HW template copied and renamed to %HW_NAME%.tex
        ) else (
            echo Operation cancelled.
            goto :eof
        )
    ) else (
        copy "%WORKSPACE_ROOT%\templates\%TEMPLATE_TYPE%\master.tex" "%HW_FILE%"
        echo HW template copied and renamed to %HW_NAME%.tex
    )
) else (
    echo Warning: HW template not found
)


echo HW project created successfully!
echo.
echo Next steps:
echo 1. Edit file: input\%HW_DIR%\%HW_NAME%.tex
echo 2. Compile with: compile.bat "%PROJECT_PATH%"
goto :eof



:echo_available_template
echo Available templates: Note, HW

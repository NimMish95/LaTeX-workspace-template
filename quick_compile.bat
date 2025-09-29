@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
:: quick_compile.bat - 快速預覽 LaTeX 輸出
:: Usage: quick_compile.bat "ProjectPath"
:: Example: quick_compile.bat "LinearAlgebra/Note"     -> 編譯 Note 項目 LinearAlgebra/Note/master.tex
:: Example: quick_compile.bat "LinearAlgebra/A/B/C"   -> 編譜 HW 項目 LinearAlgebra/A/B/C.tex

echo input argument: '%1'
if "%~1"=="" (
    echo Usage: quick_compile.bat "ProjectPath"
    echo.
    echo Examples:
    echo   quick_compile.bat "LinearAlgebra/Note"        ^(Note project^)
    echo   quick_compile.bat "LinearAlgebra/A/B/C"       ^(HW project^)

    exit /b
)

set "PROJECT_PATH=%~1"
set "WORKSPACE_ROOT=%CD%"

:: 分析項目類型和路徑

:: 如果用的是絕對路徑要把它轉成相對路徑，把 WORKSPACE_ROOT\ 前綴刪掉(要考慮多種可能的form)

set "REL_PATH=%PROJECT_PATH:c:\Active Files (custom)\LaTeX workspace\=%"
set "REL_PATH=%REL_PATH:c:/Active Files (custom)/LaTeX workspace/=%"

set "PROJECT_PATH=%REL_PATH%"

:: 處理 input\ 前綴 (如果有的話)
set "TEMP_PATH=%PROJECT_PATH%"
if /i "%TEMP_PATH:~0,6%"=="input/" (
    set "PROJECT_PATH=%TEMP_PATH:~6%"
    set "TEMP_PATH=%PROJECT_PATH%"
)
if /i "%TEMP_PATH:~0,6%"=="input\" (
    set "PROJECT_PATH=%TEMP_PATH:~6%"
    set "TEMP_PATH=%PROJECT_PATH%"
)

:: 拆解路徑，拆成前幾層+最後一層
for /f "delims=" %%i in ('powershell -command "Split-Path '%PROJECT_PATH%' -Parent"') do set "PARENT_DIR=%%i"
for /f "delims=" %%i in ('powershell -command "Split-Path '%PROJECT_PATH%' -Leaf"') do set "PROJECT_NAME=%%i"
if "%PARENT_DIR%"=="" set "PARENT_DIR=."

set "INPUT_DIR=%WORKSPACE_ROOT%\input\%PROJECT_PATH%"
set "BUILD_DIR=%WORKSPACE_ROOT%\build\%PROJECT_PATH%"
set "OUTPUT_DIR=%WORKSPACE_ROOT%\output\%PARENT_DIR%"

echo Compiling project: %PROJECT_PATH%
echo Input: %INPUT_DIR%
echo Build: %BUILD_DIR%
echo Output: %OUTPUT_DIR%\%PROJECT_NAME%.pdf
echo.

:: 確定主文件

:: case 1: input整個資料夾：找master.tex
:: case 2: input單個文件：找PROJECT_NAME.tex  (若是此情況，INPUT_DIR就會是整個input檔案含名稱的路徑)
set "MAIN_FILE="

if exist "%INPUT_DIR%\master.tex" (
    set "MAIN_FILE=%INPUT_DIR%\master.tex"
    :: 如果是master.tex，OUTPUT_DIR要往上層一層
    for /f "delims=" %%i in ('powershell -command "Split-Path '%OUTPUT_DIR%' -Parent"') do set "OUTPUT_DIR=%%i"

    REM 設定 TEXINPUTS 環境變數，LaTeX在引入檔案時會搜尋這些路徑
    REM ;%CD% 表示根目錄(基於編譯執行位置)
    REM ;%INPUT_DIR% 表示tex檔所在的資料夾
    REM 注意：開頭的 ; 很重要，表示在現有 TEXINPUTS 變數的基礎上添加新路徑
    set "TEXINPUTS=;%CD%;%INPUT_DIR%;%TEXINPUTS%"

    goto found
)

:: 原本要允許使用者輸入包含副檔名的檔案路徑，但目前試不出來
:: set "ext=%INPUT_DIR%~x1"
:: if "%ext%"==".tex" (
::     if exist "%INPUT_DIR%" (
::         set "MAIN_FILE=%INPUT_DIR%"
::         goto found
::     )
:: )

if exist "%INPUT_DIR%.tex" (
    set "MAIN_FILE=%INPUT_DIR%.tex"
    goto found
)

echo Error: No TeX file found!
goto :eof

:found
echo Found main file: %MAIN_FILE%


:: 注意：如果有同個名字的tex檔和資料夾會優先算作資料夾

:: 創建建置和輸出目錄
mkdir "%BUILD_DIR%" 2>nul
mkdir "%OUTPUT_DIR%" 2>nul

:: 主進程執行編譯區塊
call :run_compilation
goto :eof


:: 編譯區塊(不管單檔輸入還是資料夾輸入都通用)
:run_compilation
echo Using main file: %MAIN_FILE%
echo.

echo Running XeLaTeX ^(1st pass^)...
echo xelatex --output-directory="%BUILD_DIR%" "%MAIN_FILE%"
xelatex --output-directory="%BUILD_DIR%" "%MAIN_FILE%"
if errorlevel 1 (
    echo XeLaTeX first pass failed!
    goto :compilation_error
)

:: 複製最終 PDF 到輸出目錄
for %%f in ("%MAIN_FILE%") do set "PDF_NAME=%%~nf.pdf"
if exist "%BUILD_DIR%\%PDF_NAME%" (
    copy "%BUILD_DIR%\%PDF_NAME%" "%OUTPUT_DIR%\%PROJECT_NAME%.pdf" >nul
    echo.
    echo ============================================
    echo Compilation successful!
    echo PDF saved to: output\%PARENT_DIR%\%PROJECT_NAME%.pdf
    echo ============================================
) else (
    goto :compilation_error
)
goto :eof



:: 複製最終 PDF 到輸出目錄
for %%f in ("%MAIN_FILE%") do set "PDF_NAME=%%~nf.pdf"
if exist "%HW_BUILD_DIR%\%PDF_NAME%" (
    copy "%HW_BUILD_DIR%\%PDF_NAME%" "%HW_OUTPUT_DIR%\%PROJECT_NAME%.pdf" >nul
    echo.
    echo ============================================
    echo Compilation successful!
    echo PDF saved to: output\%PARENT_DIR%\%PROJECT_NAME%.pdf
    echo ============================================
) else (
    goto :compilation_error
)
goto :eof

:compilation_error
echo.
echo ============================================
echo Compilation failed!
echo Check build directory for error logs
echo ============================================
goto :eof

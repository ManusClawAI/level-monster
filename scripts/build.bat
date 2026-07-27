@echo off
REM build.bat - Build Level Monster for Android (Windows)
REM
REM Prerequisites:
REM   - Haxe 4.3+ installed (https://haxe.org/download/)
REM   - OpenFL and Lime haxelibs installed:
REM       haxelib install openfl
REM       haxelib install lime
REM       haxelib install actuate
REM   - Android SDK with NDK installed
REM   - Java JDK 17+

setlocal
cd /d "%~dp0\.."

set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=debug

echo ==========================================
echo Building Level Monster (Android)
echo Build type: %BUILD_TYPE%
echo ==========================================

REM Check dependencies
echo Checking dependencies...
call haxelib install openfl 2>nul
call haxelib install lime 2>nul
call haxelib install actuate 2>nul

REM Setup Android SDK path
if "%ANDROID_SDK%"=="" (
    if exist "%USERPROFILE%\AppData\Local\Android\Sdk" (
        set ANDROID_SDK=%USERPROFILE%\AppData\Local\Android\Sdk
        echo Using Android SDK: %ANDROID_SDK%
    )
)

REM Setup OpenFL
echo Setting up OpenFL...
call haxelib run openfl setup 2>nul

REM Build
if "%BUILD_TYPE%"=="release" (
    echo Building release APK...
    call haxelib run openfl build android -DHXCPP_M64 -Drelease
    echo.
    echo Release APK: export\android\bin\bin\LevelMonster-release.apk
) else (
    if "%BUILD_TYPE%"=="test" (
        echo Building and installing debug APK...
        call haxelib run openfl build android -DHXCPP_M64
        echo Installing on connected device...
        call adb install -r export\android\bin\bin\LevelMonster-debug.apk
        echo Launching...
        call adb shell am start -n com.levelmonster.game/.MainActivity
    ) else (
        echo Building debug APK...
        call haxelib run openfl build android -DHXCPP_M64
        echo.
        echo Debug APK: export\android\bin\bin\LevelMonster-debug.apk
    )
)

echo.
echo Build complete!
endlocal

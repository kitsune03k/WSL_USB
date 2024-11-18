@echo off

::**SEARCH_KEY 원하는 거로 수정 가능**
set SEARCH_KEY=USB-SERIAL

::관리자권한 확인
NET SESSION >nul 2>&1
if %ERRORLEVEL% neq 0 (
echo ** Priviege Error **
echo Run this batch file as an administartor!
goto theend
)

set TEMP_FILE=usbipd_list
set FOUND=false
set USB_BUSID=

setlocal enabledelayedexpansion

::usbipd 결과물 리다이렉션하여
usbipd list > %TEMP_FILE%.txt
::원하는 스트링 검색
for /f "tokens=1,2,*" %%A in (%TEMP_FILE%.txt) do (
    echo %%C | findstr /i "%SEARCH_KEY%" >nul
    if not errorlevel 1 (
        set USB_BUSID=%%A
        set FOUND=true
        goto loopBreak;
    )
)
:loopBreak
del %TEMP_FILE%.txt

if "%FOUND%" equ "false" (
    echo "** ERROR ** : %SEARCH_KEY% is not found in current USB devices"
    goto theend
)

::공유를 위한 bind, wsl에 attach
usbipd bind --busid %USB_BUSID%
usbipd attach --wsl --busid %USB_BUSID%
echo "%SEARCH_KEY%(%USB_BUSID%) is binded and attached to WSL"

:theend
endlocal
pause
@echo off
:menu
cls
echo 1. show proxy status
echo 2. Cancel Android proxy
echo 3. Set Android proxy to local IP address
echo 4. Exit
set /p choice=Enter your choice:

goto Label%choice%

:Label1
    adb connect 127.0.0.1:58526
    adb shell settings get global http_proxy
    echo proxy status showed.
    pause
    goto Menu
exit /B

:Label2
    adb connect 127.0.0.1:58526
    adb shell settings put global http_proxy :0
    adb shell settings put global https_proxy :0
    echo Proxy has been cancelled.
    pause
    goto Menu
exit /B

:Label3
    adb connect 127.0.0.1:58526
    setlocal enabledelayedexpansion
    set "adapter="
    set "ip="
    set /a count=0

    ::使用for循环从ipconfig的输出中逐行查找关键字，并提取适配器名称和IP地址
    for /f "tokens=*" %%a in ('ipconfig ^| findstr /C:"Ethernet adapter" /C:"Wireless adapter" /C:"无线局域网适配" /C:"IPv4 Address"') do (
        set line=%%a
        :: 检查当前行是否包含Ethernet adapter（以及其他可能的适配器名称），如果是，提取适配器名称
        if not "!line:Ethernet adapter=!"=="!line!" (
            set "adapter=!line:*adapter=!"
            :: 从当前行中提取适配器名称
            set "adapter=!adapter:~1!"
        )
        :: 检查当前行是否包含IPv4 Address，如果是，提取IP地址，并输出适配器名称和IP地址
        if not "!line:IPv4 Address=!"=="!line!" (
            set /a count+=1
            for /f "tokens=2 delims=:" %%b in ("!line!") do (
                set "ip=%%b"
                set "ip=!ip:~1!"
                echo !count!. Network Adapter: !adapter!  IP Address: !ip!
                set "ip_!count!=!ip!"
            )
        )
    )

    :: 接受用户输入并打印相应项目的 IP 地址
    set /p choice="Enter the number of the item to view its IP address: "
    if defined choice (
        echo IP Address: !ip_%choice%!
    )

    setlocal enableextensions
    set "configFile=%userprofile%\.config\clash\config.yaml"
    for /f "tokens=2 delims=: " %%a in (' findstr /c:"mixed-port" "%configFile%"') do set "port=%%a"
    echo The port number of Clash is %port%.
    adb shell settings put global http_proxy !ip_%choice%!:%port%
    adb shell settings put global https_proxy !ip_%choice%!%port%
    echo Proxy has been set to !ip_%choice%!:%port%.
    endlocal
    pause
    goto Menu
exit /B

:Label4
    @echo Exited
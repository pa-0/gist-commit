@echo off

:: 设置编码为 UTF-8
chcp 65001 >nul

:: 提升到管理员权限
net session >nul 2>&1
if errorlevel 1 (
    echo 提升到管理员权限...
    powershell -Command "Start-Process '%0' -Verb runAs"
    exit
)

:: 设置执行策略为 Unrestricted
powershell -Command "Set-ExecutionPolicy Unrestricted"

:: 获取当前目录
set currentDir=%~dp0

:: 运行 script.ps1 文件
powershell -ExecutionPolicy Bypass -File "%currentDir%\script.ps1" -Method "InitializeComputer"

:: 输出成功信息
echo 策略设置成功。现在您可以运行 .ps1 文件了。

exit
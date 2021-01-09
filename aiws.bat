@echo off

SET FILE_URL=https://github.com/wsldl-pg/CentWSL/releases/download/7.0.1907.3/CentOS7.zip
SET FILE_NAME=baota.zip
SET CENTOS_EXE=CentOS7.exe
SET WSL_FILE=baota
SET DOCKERBOTA=https://github.com/dooioomoo/docker-bota.git


call :Resume
goto %current%
goto :eof

setlocal
:one
echo 现在开始准备安装系统环境
echo .
echo 主要用于基于Centos和docker的前端开发和后台开发环境
echo .
echo 其中包括WSL2\DOCKER\VSCODE\GIT\COMPOSER\BOTA...等
echo .
 
SET /P AREYOUSURE=是否开始安装 (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
echo.
echo.
echo.
echo.
echo 正在安装 choco ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco feature enable -n=allowGlobalConfirmation
echo.
echo.
echo.
echo.
echo 正在安装 PHP 7.4 ...

powershell choco install --yes php --version=7.4.14
echo.
echo.
echo.
echo.
echo 正在安装 git ...

powershell choco install --yes git
echo.
echo.
echo.
echo.
echo 正在安装 composer ...

powershell choco install --yes composer
echo.
echo.
echo.
echo.
echo 正在安装 Nodejs ...

powershell choco install --yes nodejs --version=14.15.4
echo.
echo.
echo.
echo.
echo 正在安装 VSCODE ...

powershell choco install --yes vscode
echo.
echo.
echo.
echo 开始启用WINDOWS功能组件 
echo ===============================
echo.       
echo 开启虚拟机功能 ...
powershell dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
echo.        
echo 开启Hyper-V ...
powershell dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart
echo.    
echo 开启WSL ...
powershell dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
echo.
echo.
echo 开始启用WINDOWS功能组件 
echo ===============================
echo.
echo 开始启用虚拟平台 ...
powershell Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
echo.
echo.
echo 开始启用WSL ...
powershell Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

::Add script to Run key
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /d %~dpnx0 /f
echo two >%~dp0current.txt
echo -- Section one --
pause
shutdown -r -t 0

goto :eof


:two
::Remove script from Run key
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /f
del %~dp0current.txt
echo.
echo.
echo 升级WSL2 ...
start /wait powershell curl https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -o wsl_update_x64.msi
powershell msiexec /i wsl_update_x64.msi /qn
echo.
echo.
echo 设置wsl默认版本为2
powershell wsl --set-default-version 2
echo.
if not exist %FILE_NAME% (
echo 下载 CENTOS FOR WSL 7.0 ...
echo.
start /wait powershell curl %FILE_URL% -o %FILE_NAME%
echo.
)
if not exist %WSL_FILE%.exe (
echo 解压缩 ...
echo.
powershell Expand-Archive -Force %FILE_NAME% "./" && powershell Rename-Item %CENTOS_EXE% %WSL_FILE%.exe
)
echo.
echo 开始安装centos到WSL中 ...
echo.
powershell .\%WSL_FILE%.exe < nul
powershell wsl -s %WSL_FILE%
echo.
echo.
echo 开始创建docker基础文件环境 ...
echo.
powershell .\%WSL_FILE%.exe run \"[ -d /%WSL_FILE% ] || mkdir /%WSL_FILE% && cd /%WSL_FILE% && yum install git -y && git clone %DOCKERBOTA%  ./ && cp .env-example .env && mv build.bat build.sh \"
echo.
echo.
echo.
echo 请在docker中将wsl关联的%WSL_FILE%镜像设定为打开状态后
echo 运行 wsl -d %WSL_FILE%,并进入/%WSL_FILE%目录中运行 sh build.sh
echo 完成宝塔的安装
:END

goto :eof

:resume
if exist %~dp0current.txt (
    set /p current=<%~dp0current.txt
) else (
    set current=one
)
endlocal

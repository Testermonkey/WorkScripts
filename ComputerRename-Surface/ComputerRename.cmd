@echo off
pushd "%~dp0"
powershell -ExecutionPolicy bypass -command "& "%~dpn0.ps1 %*" -wait
popd
shutdown /r /t 0

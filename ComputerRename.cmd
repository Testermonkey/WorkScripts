@echo off
pushd "%~dp0"
powershell -ExecutionPolicy bypass -command "& "%~dpn0.ps1 %*"
popd


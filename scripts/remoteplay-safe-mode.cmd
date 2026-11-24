@echo off
setlocal
cd /d "%~dp0"
set REMOTEPLAY_DIAGNOSTIC_LOG=1
if exist startup-log.txt del /q startup-log.txt
start "RemotePlay Native Safe Mode" /wait "%~dp0chiaki.exe" --opengl
if exist startup-log.txt notepad startup-log.txt

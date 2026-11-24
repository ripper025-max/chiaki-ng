@echo off
setlocal
cd /d "%~dp0"
set "REMOTEPLAY_DIAGNOSTIC_LOG=1"
if exist "%TEMP%\RemotePlayNative-startup-log.txt" del /q "%TEMP%\RemotePlayNative-startup-log.txt"
start "RemotePlay Native" /wait "%~dp0chiaki.exe" --opengl
if exist "%TEMP%\RemotePlayNative-startup-log.txt" notepad "%TEMP%\RemotePlayNative-startup-log.txt"

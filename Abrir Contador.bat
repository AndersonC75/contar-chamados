@echo off
REM Abre o Contador de Chamados. O navegador abre sozinho em alguns segundos.
REM Os dados sao salvos automaticamente em chamados.json nesta pasta de rede.
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0server.ps1"

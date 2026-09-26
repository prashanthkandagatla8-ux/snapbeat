@echo off
title SnapBeat Web Studio
cd /d "%~dp0"
echo ===================================================
echo   SnapBeat Web Studio (Next.js)
echo ===================================================
echo Starting dev server at http://localhost:3000...
start "" "http://localhost:3000"
call cmd /c npm.cmd run dev

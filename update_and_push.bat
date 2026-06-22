@echo off
REM UTF-8 console + Python output, so Chinese in CSV/JSON logs render correctly.
chcp 65001 > nul
set PYTHONIOENCODING=utf-8

echo ========================================
echo   Negative Reviews Dashboard - Update
echo ========================================
echo.
echo Start: %date% %time%
echo.

cd /d "%~dp0"

echo [1/5] Exporting CSV from Feishu...
lark-cli sheets +export --url https://e10s8ombcbw.feishu.cn/sheets/U0OisV8zghcf77tOJnGcYheinoh --file-extension csv --sheet-id 0UxVhM --output-path negative_reviews.csv > "%TEMP%\feishu_export.log" 2>&1
if errorlevel 1 (
    echo ERROR: Feishu export failed!
    echo Possible: network issue / Feishu login expired / doc link changed.
    echo TIP: If you already exported the CSV manually, rename it to
    echo      negative_reviews.csv in this folder, then re-run this script
    echo      (it will skip to step 2 on next try) or just run convert_data.py.
    echo Log: %TEMP%\feishu_export.log
    pause
    exit /b 1
)
echo DONE: export complete.
echo.

echo [2/5] Converting CSV to data.json...
python convert_data.py
if errorlevel 1 (
    echo ERROR: Data conversion failed!
    echo Check Python install and the CSV format.
    pause
    exit /b 1
)
echo DONE: conversion complete.
echo.

echo [3/5] Committing to local Git...
git add data.json convert_data.py
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Update reviews: %date:~0,4%-%date:~5,2%-%date:~8,2%" > "%TEMP%\git_commit.log" 2>&1
    if errorlevel 1 (
        echo ERROR: Git commit failed! Configure git user first:
        echo   git config user.name "Your Name"
        echo   git config user.email "your@email.com"
        pause
        exit /b 1
    )
    echo DONE: committed locally.
) else (
    echo INFO: No changes detected, nothing to commit.
    pause
    exit /b 0
)
echo.

echo [4/5] Syncing with remote (pull --rebase)...
git pull --rebase origin main > "%TEMP%\git_pull.log" 2>&1
if errorlevel 1 (
    echo ERROR: Sync failed - likely a conflict on data.json.
    echo Open the repo, resolve the conflict markers, then run:
    echo   git add data.json
    echo   git rebase --continue
    echo   git push origin main
    echo Log: %TEMP%\git_pull.log
    pause
    exit /b 1
)
echo DONE: in sync with remote.
echo.

echo [5/5] Pushing to GitHub...
git push origin main > "%TEMP%\git_push.log" 2>&1
if errorlevel 1 (
    echo ERROR: Push failed! Push manually later: git push origin main
    echo Log: %TEMP%\git_push.log
    pause
    exit /b 1
)
echo DONE: pushed to GitHub!
echo.

echo ========================================
echo   Update complete!
echo ========================================
echo.
echo GitHub Pages refreshes in ~1-2 minutes.
echo URL: https://809348213-collab.github.io/negative-reviews-dashboard/
echo.
pause

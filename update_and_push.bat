@echo off
chcp 65001 >nul
echo ========================================
echo   差评看板数据更新工具
echo ========================================
echo.

cd /d "%~dp0"

echo [1/3] 正在从飞书导出最新数据...
lark-cli sheets +export --url https://e10s8ombcbw.feishu.cn/sheets/U0OisV8zghcf77tOJnGcYheinoh --file-extension csv --sheet-id 0UxVhM --output-path negative_reviews.csv >nul 2>&1
if errorlevel 1 (
    echo ❌ 飞书导出失败！请检查网络连接和飞书权限。
    pause
    exit /b 1
)
echo ✅ 导出完成

echo.
echo [2/3] 正在转换数据...
python convert_data.py
if errorlevel 1 (
    echo ❌ 数据转换失败！
    pause
    exit /b 1
)
echo ✅ 转换完成

echo.
echo [3/3] 正在提交到GitHub...
git add data.json
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "更新差评数据: %date:~0,4%-%date:~5,2%-%date:~8,2%"
    if errorlevel 1 (
        echo ❌ Git提交失败！请检查Git配置。
        pause
        exit /b 1
    )
    echo ✅ 已提交到本地仓库
    echo.
    echo 正在推送到GitHub...
    git push
    if errorlevel 1 (
        echo ❌ 推送失败！请检查网络连接和GitHub权限。
        echo 你可以稍后手动运行: git push
        pause
        exit /b 1
    )
    echo ✅ 已推送到GitHub！
    echo.
    echo 🎉 更新完成！请等待1-2分钟GitHub Pages自动刷新。
    echo 访问地址: https://你的用户名.github.io/negative-reviews-dashboard/
) else (
    echo ℹ️ 数据没有变化，跳过提交。
)

echo.
pause

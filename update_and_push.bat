@echo off
chcp 65001 >nul
echo ========================================
echo   差评看板数据更新工具
echo ========================================
echo.

cd /d "%~dp0"

echo [1/3] 正在从飞书导出最新数据...
lark-cli sheets +export --url https://e10s8ombcbw.feishu.cn/sheets/U0OisV8zghcf77tOJnGcYheinoh --file-extension csv --sheet-id 0UxVhM --output-path negative_reviews.csv
if errorlevel 1 (
    echo ❌ 飞书导出失败！
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
echo 请手动上传 data.json 到你的GitHub仓库：
echo   1. 打开 https://github.com/你的用户名/negative-reviews-dashboard
echo   2. 拖入 data.json 覆盖旧文件
echo   3. 提交后等待1-2分钟 Pages 自动刷新
echo.
echo 或者在Git仓库中运行：
echo   git add data.json
echo   git commit -m "更新差评数据: %date:~0,4%-%date:~5,2%-%date:~8,2%"
echo   git push
echo.

pause

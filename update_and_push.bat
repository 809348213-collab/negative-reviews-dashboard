@echo off
chcp 65001 >nul
echo ========================================
echo   差评看板数据更新工具
echo ========================================
echo.
echo 开始时间: %date% %time%
echo.

cd /d "%~dp0"

echo [1/4] 正在从飞书导出最新数据...
lark-cli sheets +export --url https://e10s8ombcbw.feishu.cn/sheets/U0OisV8zghcf77tOJnGcYheinoh --file-extension csv --sheet-id 0UxVhM --output-path negative_reviews.csv > "%TEMP%\feishu_export.log" 2>&1
if errorlevel 1 (
    echo ❌ 飞书导出失败！请查看日志：
    type "%TEMP%\feishu_export.log"
    echo.
    echo 可能的原因：
    echo  1. 网络连接问题
    echo  2. 飞书账号未登录或权限过期
    echo  3. 飞书文档链接已变更
    echo.
    pause
    exit /b 1
)
echo ✅ 导出完成

echo.
echo [2/4] 正在转换数据...
python convert_data.py > "%TEMP%\convert.log" 2>&1
if errorlevel 1 (
    echo ❌ 数据转换失败！请查看日志：
    type "%TEMP%\convert.log"
    echo.
    echo 可能的原因：
    echo  1. Python未安装或路径不对
    echo  2. convert_data.py文件损坏
    echo  3. CSV文件格式异常
    echo.
    pause
    exit /b 1
)
type "%TEMP%\convert.log"
echo ✅ 转换完成

echo.
echo [3/4] 正在提交到本地Git仓库...
git add data.json
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "更新差评数据: %date:~0,4%-%date:~5,2%-%date:~8,2%" > "%TEMP%\git_commit.log" 2>&1
    if errorlevel 1 (
        echo ❌ Git提交失败！请查看日志：
        type "%TEMP%\git_commit.log"
        echo.
        echo 可能的原因：
        echo  1. 未配置Git用户信息
        echo  2. 当前目录不是Git仓库
        echo.
        echo 解决方法：
        echo  运行以下命令配置Git：
        echo  git config user.name "你的名字"
        echo  git config user.email "你的邮箱"
        echo.
        pause
        exit /b 1
    )
    echo ✅ 已提交到本地仓库
) else (
    echo ℹ️ 数据没有变化，跳过提交。
    echo.
    echo 如果确实需要更新，请检查：
    echo  1. 飞书文档是否真的有新增数据
    echo  2. 数据格式是否与之前一致
    echo.
    pause
    exit /b 0
)

echo.
echo [4/4] 正在推送到GitHub...
git push > "%TEMP%\git_push.log" 2>&1
if errorlevel 1 (
    echo ❌ 推送失败！请查看日志：
    type "%TEMP%\git_push.log"
    echo.
    echo 可能的原因：
    echo  1. 网络连接问题
    echo  2. GitHub账号权限问题
    echo  3. 远程仓库地址配置错误
    echo.
    echo 你可以稍后手动运行: git push
    echo.
    pause
    exit /b 1
)
echo ✅ 已推送到GitHub！

echo.
echo ========================================
echo 🎉 更新完成！
echo ========================================
echo.
echo 请等待1-2分钟GitHub Pages自动刷新。
echo 访问地址: https://809348213-collab.github.io/negative-reviews-dashboard/
echo.
pause

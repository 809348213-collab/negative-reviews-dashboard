# 差评看板 · Negative Reviews Dashboard

电商负面评价的可视化看板。数据来自飞书表格，经脚本转换为 JSON，由 GitHub Pages 自动部署。

🔗 **线上看板**：<https://809348213-collab.github.io/negative-reviews-dashboard/>

---

## 更新数据

### 方式一：一键脚本（推荐）

双击运行 **`update_and_push.bat`**，脚本会自动完成 5 步：

| 步骤 | 动作 | 说明 |
|------|------|------|
| 1/5 | 从飞书导出 CSV | `lark-cli` 自动拉取最新表格 |
| 2/5 | 转换为 `data.json` | `python convert_data.py` |
| 3/5 | 提交本地 Git | `data.json` + `convert_data.py` |
| 4/5 | 同步远程 | `git pull --rebase`（防止推送被拒） |
| 5/5 | 推送到 GitHub | 触发 GitHub Pages 重新部署 |

成功后等 **1–2 分钟**，看板自动刷新。

### 方式二：手动导出 CSV（飞书登录失效时的备选）

当 `lark-cli` 导出失败（登录过期 / 网络 / 链接变更），改用手动方式：

```bash
# 1. 在飞书表格里手动「导出为 CSV」，把文件放到本目录
# 2. 重命名为脚本认的文件名
copy 你的导出文件.csv negative_reviews.csv

# 3. 转换
python convert_data.py

# 4. 提交并推送
git add data.json convert_data.py
git commit -m "Update reviews: 2026-06-22"
git push origin main
```

---

## 目录结构

| 文件 | 作用 | 是否提交 |
|------|------|----------|
| `index.html` | 看板前端页面 | ✅ |
| `data.json` | 看板数据（CSV 转换而来） | ✅ |
| `convert_data.py` | CSV → JSON 转换脚本 | ✅ |
| `update_and_push.bat` | 一键更新脚本 | ✅ |
| `negative_reviews.csv` | 飞书导出的源数据（每次重新生成） | ❌ 已 gitignore |
| `.gitignore` | 忽略所有 CSV / Python 缓存 | ✅ |

---

## 数据来源

- **飞书表格**：<https://e10s8ombcbw.feishu.cn/sheets/U0OisV8zghcf77tOJnGcYheinoh>
- **CSV 必须包含的列**（脚本依赖这些字段）：`店铺`、`型号`、`全局标签`、`标签情感`、`评论时间`、`消息类型`、`评论星级`

> **评论时间格式**：兼容 `2026-01-15` 和 `2026/1/15` 两种写法，脚本统一归一为 `YYYY-MM`，避免月度趋势图断裂。

---

## 常见问题

| 问题 | 解决 |
|------|------|
| **飞书导出失败** | 网络 / 登录过期 / 链接变更。改用「方式二」手动导出。 |
| **Git 提交失败** | 未配置用户信息：`git config user.name "名字"` / `git config user.email "邮箱"` |
| **推送被拒 (non-fast-forward)** | 远程有新提交。脚本已自动 `pull --rebase`；若仍冲突，解决标记后 `git rebase --continue` 再推。 |
| **看板没刷新** | GitHub Pages 有 1–2 分钟部署延迟，浏览器按 `Ctrl+F5` 强制刷新。 |

---

## 环境依赖

- **Python 3**（运行 `convert_data.py`）
- **lark-cli**（飞书命令行工具，自动导出用；手动方式不需要）
- **Git**（提交推送）

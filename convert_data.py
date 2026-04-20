#!/usr/bin/env python3
"""将飞书导出的CSV差评数据转换为可视化看板所需的JSON格式"""

import csv
import json
from collections import Counter, defaultdict
from datetime import datetime
import os

INPUT_CSV = os.path.join(os.path.dirname(os.path.abspath(__file__)), "negative_reviews.csv")
OUTPUT_JSON = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data.json")

def parse_csv():
    rows = []
    errors = 0
    with open(INPUT_CSV, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            # 跳过没有店铺字段的行（可能是格式行或空行）
            if not row.get("店铺", "").strip() and not row.get("型号", "").strip():
                errors += 1
                continue
            # 清理字段
            cleaned = {}
            for key, value in row.items():
                if key:
                    cleaned[key.strip()] = value.strip() if value else ""
            rows.append(cleaned)
    if errors:
        print(f"跳过了 {errors} 行无效数据")
    return rows

def analyze(rows):
    """分析数据并生成统计信息"""

    # 按店铺统计
    shop_counter = Counter()
    # 按型号统计
    model_counter = Counter()
    # 按标签统计
    tag_counter = Counter()
    # 按月份统计
    month_counter = Counter()
    # 按消息类型统计
    type_counter = Counter()
    # 星级分布
    rating_counter = Counter()

    for row in rows:
        shop = row.get("店铺", "")
        model = row.get("型号", "")
        tag = row.get("全局标签", "")
        tag_sentiment = row.get("标签情感", "")

        if shop:
            shop_counter[shop] += 1
        if model:
            model_counter[model] += 1
        if tag:
            tag_label = f"{tag}({tag_sentiment})" if tag_sentiment else tag
            tag_counter[tag_label] += 1

        # 月份统计
        comment_time = row.get("评论时间", "")
        if comment_time and len(comment_time) >= 7:
            month = comment_time[:7]  # YYYY-MM
            month_counter[month] += 1

        # 消息类型
        msg_type = row.get("消息类型", "")
        if msg_type:
            type_counter[msg_type] += 1

        # 星级
        rating = row.get("评论星级", "")
        if rating:
            try:
                rating_counter[int(rating)] += 1
            except ValueError:
                pass

    return {
        "shop_dist": dict(shop_counter.most_common()),
        "model_dist": dict(model_counter.most_common()),
        "tag_dist": dict(tag_counter.most_common(15)),
        "month_dist": dict(sorted(month_counter.items())),
        "type_dist": dict(type_counter.most_common()),
        "rating_dist": dict(sorted(rating_counter.items())),
    }

def main():
    rows = parse_csv()
    stats = analyze(rows)

    output = {
        "total_count": len(rows),
        "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "statistics": stats,
        "reviews": rows,
    }

    os.makedirs(os.path.dirname(OUTPUT_JSON), exist_ok=True)
    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"已转换 {len(rows)} 条评论数据")
    print(f"输出文件: {OUTPUT_JSON}")
    print(f"\n统计概览:")
    print(f"  店铺分布: {stats['shop_dist']}")
    print(f"  型号分布: {stats['model_dist']}")
    print(f"  标签分布: {list(stats['tag_dist'].keys())[:10]}")
    print(f"  月份分布: {stats['month_dist']}")
    print(f"  星级分布: {stats['rating_dist']}")

if __name__ == "__main__":
    main()

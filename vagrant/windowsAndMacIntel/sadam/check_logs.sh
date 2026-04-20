#!/bin/bash

# اسم الخدمة التي تريد فحصها (يمكنك تغييرها عند تشغيل السكريبت)
SERVICE_NAME=${1:-db01}

echo "--- Searching for errors in logs for: $SERVICE_NAME ---"

# قائمة الكلمات المفتاحية المجمعة
KEYWORDS="error|failed|failure|fatal|critical|denied|refused|timeout|exception|unreachable|panic"

# تنفيذ البحث مع تلوين النتائج لتسهيل القراءة
docker compose logs $SERVICE_NAME | grep -Ei --color=always "$KEYWORDS"

if [ $? -ne 0 ]; then
    echo "No critical errors found in the current logs."
fi

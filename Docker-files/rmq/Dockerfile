FROM rabbitmq:3-management-alpine

# تعيين متغيرات البيئة
ENV RABBITMQ_DEFAULT_USER=test
ENV RABBITMQ_DEFAULT_PASS=test

# التأكد من صلاحيات المجلد والملفات
# نستخدم root مؤقتاً لإصلاح الصلاحيات ثم نعود لمستخدم rabbitmq
USER root

# إنشاء المجلد وإعطاء الصلاحيات
RUN mkdir -p /var/lib/rabbitmq && \
    chown -R rabbitmq:rabbitmq /var/lib/rabbitmq && \
    chmod -R 700 /var/lib/rabbitmq

# العودة للمستخدم الافتراضي
USER rabbitmq

EXPOSE 5672 15672
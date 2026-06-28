FROM tomcat:10.1-jdk17-temurin

# تنظيف المجلد الافتراضي لتومكات
RUN rm -rf /usr/local/tomcat/webapps/*

# نسخ ملف الـ war الجاهز الذي تم بناؤه في مرحلة Jenkins الأولى
# (افترضنا أن المسار هو target/vprofile-v2.war أو حسب المسار الناتج عندك)
COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
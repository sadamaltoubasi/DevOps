FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app
RUN apk add --no-cache git
RUN git clone https://github.com/sadamaltoubasi/vprofile-project.git .
RUN git checkout cicd-jenkbean
RUN mvn clean package -DskipTests

# ﺎﻠﻣﺮﺤﻟﺓ ﺎﻠﺛﺎﻨﻳﺓ: ﺎﻠﺘﺸﻐﻴﻟ ﺏﺎﺴﺘﺧﺩﺎﻣ Java 8
FROM tomcat:9.0-jdk8-openjdk-slim

# ﻼﺤﻇ: ﻻ ﻱﻮﺟﺩ JAVA_OPTS ﻪﻧﺍ
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
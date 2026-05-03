FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
RUN apk add --no-cache git
WORKDIR /app
RUN git clone https://github.com/sadamaltoubasi/vprofile-project.git .
RUN git checkout cicd-jenkbean
RUN mvn clean package -DskipTests

FROM tomcat:10-jdk17-openjdk-slim
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]

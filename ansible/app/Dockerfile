FROM maven:3-eclipse-temurin-17 AS build_image
RUN apt-get update && apt-get install -y git
WORKDIR /app
RUN git clone https://github.com/sadamaltoubasi/vprofile-project.git .
RUN git checkout cd-aws && mvn clean install

FROM tomcat:10.1-jdk17-temurin

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build_image /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]

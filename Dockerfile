#FROM gradle:4.8.0-jdk8-alpine
#WORKDIR /home/gradle/project
#USER root
#RUN apk update
#ENV GRADLE_USER_HOME /home/gradle/project
# COPY . /home/gradle/project
#RUN gradle build

FROM java:jre-alpine

# WORKDIR /home/gradle/project

COPY  springboot.jar .

ENTRYPOINT java -jar springboot.jar

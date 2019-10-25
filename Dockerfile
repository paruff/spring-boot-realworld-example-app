#FROM gradle:4.8.0-jdk8-alpine
#WORKDIR /home/gradle/project
#USER root
#RUN apk update
#ENV GRADLE_USER_HOME /home/gradle/project
# COPY . /home/gradle/project
#RUN gradle build
FROM openjdk:8-jre-alpine
USER root
# RUN apk update
# WORKDIR /home/gradle/project
# COPY --from=0 /home/gradle/project/build/libs/project-0.0.2.jar /app.jar
COPY ./build/libs/* ./app.jar
EXPOSE 8080
CMD ["java","-jar","app.jar"]

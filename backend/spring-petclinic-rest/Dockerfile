#
# Build stage
#
FROM maven:3.6.0-jdk-11-slim AS build
COPY src /app/src
COPY pom.xml /app
RUN mvn -f /app/pom.xml clean package
 
#
# Package stage
#
FROM openjdk:11-jre-slim
COPY --from=build /app/target/spring-petclinic-rest-2.4.2.jar /usr/local/lib/spring-petclinic-rest-2.4.2.jar
EXPOSE 9966
ENTRYPOINT ["java","-jar","/usr/local/lib/spring-petclinic-rest-2.4.2.jar"]
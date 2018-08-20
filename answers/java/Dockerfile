# These args allow the base image version to be easily adjusted
ARG JAVA_VER=8
ARG JAVA_DIST=alpine

# Build stage using JDK
FROM openjdk:${JAVA_VER}-jdk-${JAVA_DIST} as build
# the jdk image does not have maven installed, add it
RUN apk add --no-cache maven
WORKDIR /java
# copy just the pom file and download all dependencies to reduce build times
COPY pom.xml /java/pom.xml
ARG MVN_DEP_CACHE
RUN mvn dependency:go-offline
# copy the rest of the code and build the jar
COPY . /java
RUN mvn package -Dmaven.test.skip=true

# Run stage using JRE
FROM openjdk:${JAVA_VER}-jre-${JAVA_DIST}
# The volume line has been removed to avoid anonymous volumes
ARG JAR_FILE=gs-spring-boot-docker-0.1.0.jar
COPY --from=build /java/target/${JAR_FILE} /java/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/java/app.jar"]


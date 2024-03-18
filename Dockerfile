# Use Maven for building
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean install -DskipTests

# Use Zulu OpenJDK 17 for runtime
FROM azul/zulu-openjdk:17
WORKDIR /app
COPY --from=build /app/target/spring-petclinic*.jar /app/spring-petclinic.jar
CMD ["java", "-jar", "-Dserver.port=8085", "spring-petclinic.jar"]


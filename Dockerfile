FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY ProjectSynapse_v2.java .
RUN javac ProjectSynapse_v2.java
EXPOSE 5001 8001
CMD ["java", "ProjectSynapse_v2"]

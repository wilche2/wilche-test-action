# 使用 Maven 镜像作为构建环境
FROM maven:3.8.3-jdk-8 AS builder

# 设置工作目录
WORKDIR /app

# 复制项目的 pom.xml 文件
COPY pom.xml .

# 下载 Maven 依赖（这一步会在后续的构建缓存中被重用）
RUN mvn dependency:go-offline

# 复制整个项目到镜像中
COPY . .

# 构建项目，生成 JAR 文件
RUN mvn package

# 使用 OpenJDK 镜像作为运行时环境
FROM openjdk:8-jre-alpine

# 设置工作目录
WORKDIR /app

# 定义构建参数来接收版本号
ARG VERSION=1.0.5-RELEASE

# 从构建环境中复制生成的 JAR 文件到镜像中
COPY --from=builder /app/target/wilche-test-action-${VERSION}.jar /app/app.jar

# 定义容器启动时执行的命令
CMD ["java", "-jar", "app.jar"]

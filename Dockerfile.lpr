FROM maven:3.8.1-openjdk-17-slim AS MAVEN_BUILD
WORKDIR /build/
COPY pom.xml /build/
COPY src /build/src/
RUN mvn package

FROM openjdk:17-alpine

# Removing apk package manager
RUN rm -f /sbin/apk && \
    rm -rf /etc/apk && \
    rm -rf /lib/apk && \
    rm -rf /usr/share/apk && \
    rm -rf rm -rf /var/lib/apk

# Adding a user and group called "boot"
RUN addgroup boot -g 1337 && \ 
    adduser -D -h /home/boot -u 1337 -s /bin/ash boot -G boot

# Changing the context that shall run the below commands with User "boot" instead of root
USER boot
WORKDIR /home/boot

# By default even in a non-root context, Docker copies the file as root. Hence its best practice to chown
# the files being copied as the user. https://stackoverflow.com/a/44766666/1679541
COPY --chown=boot:boot --from=MAVEN_BUILD /build/target/springbootmaven.jar /home/boot/springbootmaven.jar
EXPOSE 8080
CMD java -jar /home/boot/springbootmaven.jar
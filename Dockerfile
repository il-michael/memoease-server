FROM ubuntu:22.04
LABEL maintainer="b.gamard@sismics.com"

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
ENV JAVA_OPTIONS -Dfile.encoding=UTF-8 -Xmx1g
ENV JETTY_VERSION 11.0.20
ENV JETTY_HOME /opt/jetty

# Install necessary packages
RUN apt-get update && \
    apt-get -y -q --no-install-recommends install \
    vim less procps unzip wget tzdata openjdk-11-jdk \
    ffmpeg mediainfo tesseract-ocr \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN dpkg-reconfigure -f noninteractive tzdata

# Install Jetty
RUN wget -nv -O /tmp/jetty.tar.gz \
    "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/${JETTY_VERSION}/jetty-home-${JETTY_VERSION}.tar.gz" \
    && tar xzf /tmp/jetty.tar.gz -C /opt \
    && mv /opt/jetty* /opt/jetty \
    && useradd jetty -U -s /bin/false \
    && chown -R jetty:jetty /opt/jetty \
    && chmod +x /opt/jetty/bin/jetty.sh

EXPOSE 8080

# Copy the entire project directory into the Jetty webapps directory
COPY ./docs-web/src/main/webapp/. /opt/jetty/webapps/docs/
RUN chown -R jetty:jetty /opt/jetty/webapps/docs/

# Set working directory
WORKDIR /opt/jetty

# Start Jetty
CMD ["java", "-jar", "/opt/jetty/start.jar"]

# Use the UBI8 base image
FROM registry.access.redhat.com/ubi8/ubi:latest

# Set up a non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID appuser && \
    useradd -m -u $USER_ID -g appuser -s /bin/bash appuser

# Install necessary packages and Java 17
RUN yum update -y && \
    yum install -y curl java-17-openjdk && \
    yum clean all

# Download and extract Tomcat 10
ENV TOMCAT_VERSION=10.1.33
RUN curl -L -o /tmp/apache-tomcat.tar.gz \
    https://downloads.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xzf /tmp/apache-tomcat.tar.gz -C /opt && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
    rm /tmp/apache-tomcat.tar.gz

# Set up environment variables
ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

# Download Supercronic
RUN curl -L -o /usr/local/bin/supercronic \
    https://github.com/aptible/supercronic/releases/download/v0.2.1/supercronic-linux-amd64 && \
    chmod +x /usr/local/bin/supercronic

# Copy application code to webapps folder
COPY --chown=appuser:appuser . $CATALINA_HOME/webapps/

# Copy custom cron job script and cron job configuration
COPY mycronjob.sh /usr/local/bin/mycronjob.sh
RUN chmod +x /usr/local/bin/mycronjob.sh

# Create a directory for cron jobs and copy the cron job file
RUN mkdir -p /etc/cron.d && chown -R appuser:appuser /etc/cron.d
COPY cronjobs /etc/cron.d/cronjobs
RUN chmod 0644 /etc/cron.d/cronjobs && \
    ls -lrt $CATALINA_HOME/bin && \
    chmod 0766 $CATALINA_HOME/bin/catalina.sh && \
    chown -R appuser:appuser /opt/tomcat && \ 
    ls -lrt $CATALINA_HOME/bin

# Set permissions and change user to non-root
USER appuser

# Define entrypoint to run both Supercronic and Tomcat
ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/supercronic /etc/cron.d/cronjobs & $CATALINA_HOME/bin/catalina.sh run"]

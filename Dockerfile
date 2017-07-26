FROM centos
MAINTAINER "Liatrio"

# Java Env Variables
#ENV JAVA_VERSION=1.8.0_45
#ENV JAVA_TARBALL=server-jre-8u45-linux-x64.tar.gz
#ENV JAVA_HOME=/opt/java/jdk${JAVA_VERSION}

# Swarm Env Variables (defaults)
ENV SWARM_MASTER=http://jenkins:8080/jenkins/
ENV SWARM_USER=jenkins
ENV SWARM_PASSWORD=jenkins

# Slave Env Variables
ENV SLAVE_NAME="Swarm_Slave"
ENV SLAVE_LABELS="docker aws ldap"
ENV SLAVE_MODE="exclusive"
ENV SLAVE_EXECUTORS=1
ENV SLAVE_DESCRIPTION="Core Jenkins Slave"

# Pre-requisites
RUN yum update -y && yum -y install epel-release
RUN yum install -y which \
    yum install java-1.8.0-openjdk-devel \
    git \
    wget \
    tar \
    zip \
    unzip \
    openldap-clients \
    openssl \
    python-pip \
    libxslt && \
    yum clean all 

RUN pip install awscli

RUN curl -fsSL https://get.docker.com/ | sh

# Install Java
#RUN wget -q --no-check-certificate --directory-prefix=/tmp \
#         --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
#            http://download.oracle.com/otn-pub/java/jdk/8u45-b14/${JAVA_TARBALL} && \
#          mkdir -p /opt/java && \
#              tar -xzf /tmp/${JAVA_TARBALL} -C /opt/java/ && \
#            alternatives --install /usr/bin/java java /opt/java/jdk${JAVA_VERSION}/bin/java 100 && \
#                rm -rf /tmp/* && rm -rf /var/log/*

# Make Jenkins a slave by installing swarm-client
RUN curl -s -o /bin/swarm-client.jar -k http://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/2.0/swarm-client-2.0-jar-with-dependencies.jar

# Start Swarm-Client
CMD java -jar /bin/swarm-client.jar -executors ${SLAVE_EXECUTORS} -description "${SLAVE_DESCRIPTION}" -master ${SWARM_MASTER} -username ${SWARM_USER} -password ${SWARM_PASSWORD} -name "${SLAVE_NAME}" -labels "${SLAVE_LABELS}" -mode ${SLAVE_MODE}

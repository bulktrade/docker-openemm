FROM centos:7
RUN yum install -y deltarpm ld-linux.so.2 sqlite glibc.i686 libxml2.i686 zlib.i686 mysql MySQL-python libxml2 wget logrotate
RUN groupadd openemm
RUN useradd -m -g openemm -d /home/openemm -c "OpenEMM-2015" openemm

RUN mkdir -p /opt/openemm
WORKDIR /opt/openemm

RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz"
RUN tar -xvzf jdk-8u45-linux-x64.tar.gz && ln -s jdk1.8.0_45 java
RUN wget http://apache.mirrors.pair.com/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz
RUN tar -xvzf apache-tomcat-8.0.24.tar.gz && ln -s apache-tomcat-8.0.24 tomcat

WORKDIR /home/openemm
RUN wget "http://downloads.sourceforge.net/project/openemm/OpenEMM%20software/OpenEMM%202015/OpenEMM-2015_R2-bin_x64.tar.gz" -O OpenEMM-2015_R2-bin_x64.tar.gz
RUN tar xzvpf OpenEMM-2015_R2-bin_x64.tar.gz
RUN mkdir -p /usr/share/doc/OpenEMM-2015
RUN mv USR_SHARE/* /usr/share/doc/OpenEMM-2015 && rm -r USR_SHARE

RUN touch .NOT_CONFIGURED

ADD run.sh /run.sh

EXPOSE 8080
CMD ["/run.sh"]

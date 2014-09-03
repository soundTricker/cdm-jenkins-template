cd /tmp/
wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war
cp /tmp/jenkins.war /opt/apache-tomcat/webapps
chown tomcat:tomcat /opt/apache-tomcat/webapps/jenkins.war

PROJECT_HOME=/d/workspaces/fl_git/prodBuild/finishline
JAVA_HOME=/d/java_dev/jdk/jdk1.5.0_14
ANT_HOME=/d/java_dev/apache-ant-1.6.5
ANT_CONTRIB_HOME=/d/java_dev/ant-contrib
YUI_COMPRESSOR_HOME=/d/java_dev/yuicompressor-2.4.2
PATH=${JAVA_HOME}/bin:${ANT_HOME}/bin:${ANT_CONTRIB_HOME}:${PATH}
CLASSPATH=${JAVA_HOME}/lib:${ANT_CONTRIB_HOME}/ant-contrib-1.0b3.jar:${YUI_COMPRESSOR_HOME}/build/YUIAnt.jar:${YUI_COMPRESSOR_HOME}/build/yuicompressor-2.4.2.jar
DYNAMO_HOME=/d/ATG/ATG2007.1

ANT_OPTS="-Xms128m -Xmx512m -Duser.language=en -XX:PermSize=128M -XX:MaxPermSize=256M"

echo removing build.properties
rm /d/workspaces/fl_git/finishline/build.properties

echo copying development build.properties to build.properties
#switch to the product build.properties
cp -vrf /d/workspaces/fl_git/finishline/build.development.properties /d/workspaces/fl_git/prodBuild/finishline/build.properties

#echo stop the server so the build doesnt fail
stop server
/d/opt/jboss-4.0.5.GA/bin/shutdown.sh --shutdown

echo run the build
ant build-deploy-all-withclean -f ${PROJECT_HOME}/build.xml

echo start the server
/d/opt/jboss-4.0.5.GA/bin/run.sh --configuration=finishline --host=localhost
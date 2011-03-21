set PROJECT_HOME=D:\workspaces\fl_git\finishline
set JAVA_HOME=D:\java_dev\jdk\jdk1.5.0_14
set ANT_HOME=D:\java_dev\apache-ant-1.6.5
set ANT_CONTRIB_HOME=D:\java_dev\ant-contrib
set YUI_COMPRESSOR_HOME=D:\java_dev\yuicompressor-2.4.2
set PATH=%JAVA_HOME%\bin;%ANT_HOME%\bin;%ANT_CONTRIB_HOME%;%PATH%
set CLASSPATH=%JAVA_HOME%\lib;%ANT_CONTRIB_HOME%\ant-contrib-1.0b3.jar;%YUI_COMPRESSOR_HOME%\build\YUIAnt.jar;%YUI_COMPRESSOR_HOME%\build\yuicompressor-2.4.2.jar

rem set ANT_OPTS=-Xmx512M
set ANT_OPTS=-Xms128m -Xmx512m -Duser.language=en -XX:PermSize=128M -XX:MaxPermSize=256M
rem set ANT_ARGS=-logger org.apache.tools.ant.listener.AnsiColorLogger

rem ant -f %PROJECT_HOME%\build.xml
rem ant build-deploy-all-noclean-min-merge -f %PROJECT_HOME%\build.xml 
rem ant build-deploy-all-withclean-min-merge -f %PROJECT_HOME%\build.xml
ant deploy-webapp.war-to-ear-min-css -f %PROJECT_HOME%\build.xml
rem ant deploy-webapp.war-to-ear -f %PROJECT_HOME%\build.xml

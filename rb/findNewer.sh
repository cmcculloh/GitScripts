touch --date "2011-01-10" /tmp/foo
find /opt/jboss/server/03finishline/deploy/finishline.ear/web-app.war/global/promos/nike-track-club/ -newer /tmp/foo | mail -s "[NTC] These files have changed on 102" cmcculloh@finishline.com

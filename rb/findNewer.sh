cd /opt/jboss/server/03finishline/deploy/finishline.ear/web-app.war/global/promos/nike-track-club/
touch --date "2011-01-07" /tmp/foo
find . -newer /tmp/foo | mail -s "[NTC] These files have changed on 102" cmcculloh@finishline.com

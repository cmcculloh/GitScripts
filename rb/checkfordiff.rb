require 'fileutils'
include FileUtils

puts <<-eot
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

 ______              __     _______      __     _______          __
/_  __/_______ _____/ /__  / ___/ /__ __/ /    / ___/ / ___ ____/ /_____ ____
 / /  / __/ _ `/ __/  '_/ / /__/ // // / _ \\  / /__/ _ | -_) __/  '_/ -_) __/
/_/  /_/  \\_,_/\\__/_/\\_\\  \\___/_/ \\_,_/_.__/  \\___/_//_|__/\\__/_/\\_\\\\__/_/

================================================================================
eot

puts ""
puts "=========================================================================="
puts "Start by updating nike-track-club repo from 102"
puts "=========================================================================="
puts ""

puts ""
puts ".........................................................................."
puts "moving into nike-track-club repo"
#move into the Nike Track Club repository
Dir.chdir("/workspaces/nike-track-club")
#Dir.chdir("/workspaces/fl_git/nike-track-club")
puts "moved into nike-track-club repo"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""


#get the status
puts ".........................................................................."
puts "running git status"
status = system( "git status" )
puts "ran git status"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running git pull origin master"
#pull nike-track-club/master
pull = system( "git pull origin master" )
puts "ran git pull origin master"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running git status"
#get the status
status = system( "git status" )
puts "ran git status"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "copying files down from server"
#copy files down from 102
`scp -r dynuser@172.17.2.102:/opt/jboss/server/04finishline/deploy/finishline.ear/web-app.war/global/promos/nike-track-club/* /workspaces/nike-track-club/`
`expect ssword:`
`send "dynuser\r"`
#copy_files = system( "scp -r dynuser@172.17.2.102:/opt/jboss/server/04finishline/deploy/finishline.ear/web-app.war/global/promos/nike-track-club/* /d/workspaces/fl_git/nike-track-club/" )
puts "copied files down from server"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running git status"
#get the status
status = system( "git status" )
puts "ran git status"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ""
puts "=========================================================================="
puts "Done with nike-track-club repo, moving into finishline repo"
puts "=========================================================================="
puts ""


puts ".........................................................................."
puts "moving into finishline repo"
#Move into the finishline repository
Dir.chdir("/workspaces/nike-track-club-fl/")
#Dir.chdir("/workspaces/fl_git/finishline/")
puts "moved into finishline repo"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
#check out stage
puts "checking out stage"
checkout = system( "git checkout stage" )
puts "checked out stage"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "fetching"
fetch = system( "git fetch" )
puts "fetched"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "resetting"
reset = system( "git reset --hard" )
puts "reset"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
#Pull stage to make sure it is up to date with last prod deploy
puts "pulling fl stage"
pull_stage = system( "git pull fl stage" )
puts "pulled stage"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
#Copy contents of nike-track-club repo into stage nike-track-club spot
puts "copying files from ntc to stage branch"
cp_r "/workspaces/nike-track-club/", "/workspaces/nike-track-club-fl/modules/base/j2ee-apps/base/web-app.war/global/promos/"
#cp_r "/workspaces/fl_git/nike-track-club/", "/workspaces/fl_git/finishline/modules/base/j2ee-apps/base/web-app.war/global/promos/"
puts "copied files"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running git status"
system( "git status ")
#look for changes
stage_status = `git status`
puts "ran git status"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running regex on git status to determine if changes occured"
#determine if changes occurred.
regex = Regexp.new(/nothing to commit \(working directory clean\)/);
matchdata = regex.match(stage_status)
if matchdata
	puts "No changes detected"
else
	puts "CHANGES WERE MADE!"
end
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "sending email"
#send e-mail indicating whether changes occured
if matchdata
	`echo "Nike Track Club is NOT changed" | mail -s "[NTC] NO CHANGES to Nike Track Club" cmcculloh@finishline.com`
else
	`echo "Nike Track Club files HAVE CHANGED" | mail -s "[NTC] CHANGES to Nike Track Club!!!!" cmcculloh@finishline.com`
end
puts "sent email"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts "================================================================================"
puts "ALL DONE!"
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

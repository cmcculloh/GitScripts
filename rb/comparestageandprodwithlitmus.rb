require 'fileutils'
include FileUtils

puts <<-eot
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

.______              __     _______      __     _______          __
/_  __/_______ _____/ /__  / ___/ /__ __/ /    / ___/ / ___ ____/ /_____ ____
./ /  / __/ _ `/ __/  '_/ / /__/ // // / _ \\  / /__/ _ | -_) __/  '_/ -_) __/
/_/  /_/  \\_,_/\\__/_/\\_\\  \\___/_/ \\_,_/_.__/  \\___/_//_|__/\\__/_/\\_\\\\__/_/

================================================================================
eot


puts ""
puts "=========================================================================="
puts "Pulling latest version of litmus branch"
puts "=========================================================================="
puts ""


puts ".........................................................................."
puts "moving into litmus repo"
#Move into the finishline repository
Dir.chdir("/workspaces/litmus-fl/")
puts "moved into litmus repo"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
#check out stage
puts "checking out current_nike_track_club"
checkout = system( "git checkout nike-track-club-litmus" )
puts "checked out current_nike_track_club"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "fetching"
fetch = system( "git fetch --all" )
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
puts "pulling fl nike-track-club-litmus"
pull_stage = system( "git pull fl nike-track-club-litmus" )
puts "pulled nike-track-club-litmus"
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

puts ""
puts "=========================================================================="
puts "Pulling latest version of master, to compare to litmus"
puts "=========================================================================="
puts ""


puts ".........................................................................."
puts "moving into compare repo"
#Move into the finishline repository
Dir.chdir("/workspaces/nike-track-club-to-compare/")
puts "moved into compare repo"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
#check out stage
puts "checking out master"
checkout = system( "git checkout master" )
puts "checked out master"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "resetting"
reset = system( "git reset --hard" )
puts "reset"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "fetching"
fetch = system( "git fetch --all" )
puts "fetched"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
#Pull stage to make sure it is up to date with last prod deploy
puts "pulling origin master"
pull_master = system( "git pull origin master" )
puts "pulled origin master"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running git status"
system( "git status ")
master_status = `git status`
puts "ran git status"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""


puts ".........................................................................."
puts "running diff -r /d/workspaces/nike-track-club-to-compare/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/ /d/workspaces/litmus-fl/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/"
#look for changes
master_diff = `diff -r /d/workspaces/nike-track-club-to-compare/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/ /d/workspaces/litmus-fl/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/`
puts master_diff
puts "ran diff -r /d/workspaces/nike-track-club-to-compare/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/ /d/workspaces/litmus-fl/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/"

#determine if changes occurred.
mastermatch = false

if master_diff.length == 0
	puts "MASTER MATCHES LITMUS BRANCH"
	mastermatch = true
else
	puts "MASTER DOES NOT MATCH LITMUS BRANCH"
	mastermatch = false
end
puts "``````````````````````````````````````````````````````````````````````````"
puts ""


puts ""
puts "=========================================================================="
puts "Pulling latest version of stage, to compare to litmus"
puts "=========================================================================="
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
pull_master = system( "git pull origin stage" )
puts "pulled stage"
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
puts "running diff -r /d/workspaces/nike-track-club-to-compare/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/ /d/workspaces/litmus-fl/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/"
#look for changes
stage_diff = `diff -r /d/workspaces/nike-track-club-to-compare/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/ /d/workspaces/litmus-fl/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/`
puts stage_diff
puts "ran diff -r /d/workspaces/nike-track-club-to-compare/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/ /d/workspaces/litmus-fl/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/"

#determine if changes occurred.
stagematch = false

if stage_diff.length == 0
	puts "STAGE MATCHES LITMUS BRANCH"
	stagematch = true
else
	puts "STAGE DOES NOT MATCH LITMUS BRANCH"
	stagematch = false
end
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "sending email"
#send e-mail indicating whether changes occured
if stagematch && mastermatch
	`echo "Nike Track Club has probably not reverted" | mail -s "[NTC] Nike Track Club OK" cmcculloh@finishline.com`
else
	if stagematch
		`echo "Nike Track Club MIGHT HAVE REVERTED ON PROD. Some files having to do with nike, track, club or nike-track-club are different on master, but not stage, than the files in the Litmus branch" | mail -s "[NTC] Nike Track Club MIGHT HAVE REVERTED!!!!" cmcculloh@finishline.com`
	end
	`echo "Nike Track Club check failed. Stage (and possibly master) does not match Litmus branch" | mail -s "[NTC] Nike Track Club Litmus branch does not match stage/master" cmcculloh@finishline.com`
end
puts "sent email"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""


if stagematch
	puts "STAGE MATCHES LITMUS BRANCH"
else
	puts "STAGE DOES NOT MATCH LITMUS BRANCH"
end


if mastermatch
	puts "MASTER MATCHES LITMUS BRANCH"
else
	puts "MASTER DOES NOT MATCH LITMUS BRANCH"
end
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts "================================================================================"
puts "ALL DONE!"
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

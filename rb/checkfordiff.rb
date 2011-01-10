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
puts "Start by updating nike-track-club repo from 102"
puts "=========================================================================="
puts ""

puts ""
puts ".........................................................................."
puts "moving into nike-track-club repo"
#move into the Nike Track Club repository
Dir.chdir("/workspaces/nike-track-club")
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
#system( "scp -r dynuser@172.17.2.102:/opt/jboss/server/04finishline/deploy/finishline.ear/web-app.war/global/promos/nike-track-club/* /workspaces/nike-track-club/" )
#system( "scp -r dynuser@172.17.2.102:/opt/jboss/server/03finishline/deploy/finishline.ear/web-app.war/global/promos/nike-track-club/* /d/workspaces/nike-track-club/" )
puts "copied files down from server"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running git status"
system( "git status ")
#look for changes
status_201 = `git status`
puts "ran git status"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running regex on git status to determine if changes occured"
#determine if changes occurred.
regex = Regexp.new(/nothing to commit \(working directory clean\)/);
matchdata = regex.match(status_201)
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
	`echo "Nike Track Club on 201 is NOT changed" | mail -s "[NTC] NO CHANGES to Nike Track Club on 201" cmcculloh@finishline.com`
else
	`echo "Nike Track Club files on 201 HAVE CHANGED" | mail -s "[NTC] CHANGES to Nike Track Club on 201!!!!" cmcculloh@finishline.com`
end
puts "sent email"
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
puts "moved into finishline repo"
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
puts "pulling fl stage"
pull_stage = system( "git pull fl stage" )
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
puts "running regex on git status to determine if changes occured"
#determine if changes occurred.
regex = Regexp.new(/nothing to commit \(working directory clean\)/)

stagematchNTCdata = false
stagematchdata = regex.match(stage_status)
stagematches = false

if stagematchdata
	puts "STAGE MATCHES LITMUS BRANCH"
	stagematches = true
else
	puts "STAGE DOES NOT MATCH LITMUS BRANCH"
	regexNTC = Regexp.new(/(nike\-track\-club)||(nike)||(track)||(club)/)
	prodmatchNTCdata = regexNTC.match(stage_status)
	if prodmatchNTCdata
		puts "PROD HAS CHANGES TO A NIKE FILE, POSSIBLY NIKE-TRACK-CLUB"
	end
end
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
puts "pulling fl master"
pull_master = system( "git pull fl master" )
puts "pulled master"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running git status"
system( "git status ")
#look for changes
master_status = `git status`
puts "ran git status"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "running regex on git status to determine if changes occured"
#determine if changes occurred.
regex = Regexp.new(/nothing to commit \(working directory clean\)/)
prodmatchdata = regex.match(master_status)

prodmatches = false
prodmatchNTCdata = false
if prodmatchdata
	puts "PROD MATCHES LITMUS BRANCH"
	prodmatches = true
else
	puts "PROD DOES NOT MATCH LITMUS BRANCH"
	regexNTC = Regexp.new(/(nike\-track\-club)||(nike)||(track)||(club)/)
	prodmatchNTCdata = regexNTC.match(master_status)
	if prodmatchNTCdata
		puts "PROD HAS CHANGES TO A NIKE FILE, POSSIBLY NIKE-TRACK-CLUB"
	end
end
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts ".........................................................................."
puts "sending email"
#send e-mail indicating whether changes occured
if stagematches && prodmatches
	`echo "Nike Track Club has probably not reverted" | mail -s "[NTC] Nike Track Club OK" cmcculloh@finishline.com`
else
	if prodmatchNTCdata || stagematchNTCdata
		`echo "Nike Track Club MIGHT HAVE REVERTED ON PROD. Some files having to do with nike, track, club or nike-track-club are different on stage or master than they are in the Litmus branch" | mail -s "[NTC] Nike Track Club MIGHT HAVE REVERTED!!!!" cmcculloh@finishline.com`
	end
	`echo "Nike Track Club check failed. Either stage or master do not match Litmus branch, but changes appear to be unrelated to Nike Track Club" | mail -s "[NTC] Nike Track Club Litmus branch does not match stage/master" cmcculloh@finishline.com`
end
puts "sent email"
puts "``````````````````````````````````````````````````````````````````````````"
puts ""


if matchdata
	puts "Files on 201 match local cache of 201"
else
	puts "Changes were made on 201!"
end

if stagematchdata
	puts "STAGE MATCHES LITMUS BRANCH"
else
	puts "STAGE DOES NOT MATCH LITMUS BRANCH"
	regexNTC = Regexp.new(/(nike\-track\-club)||(nike)||(track)||(club)/)
	prodmatchNTCdata = regexNTC.match(stage_status)
	if prodmatchNTCdata
		puts "PROD HAS CHANGES TO A NIKE FILE, POSSIBLY NIKE-TRACK-CLUB"
	end
end


if prodmatchdata
	puts "PROD MATCHES LITMUS BRANCH"
else
	puts "PROD DOES NOT MATCH LITMUS BRANCH"
	regexNTC = Regexp.new(/(nike\-track\-club)||(nike)||(track)||(club)/)
	prodmatchNTCdata = regexNTC.match(master_status)
	if prodmatchNTCdata
		puts "PROD HAS CHANGES TO A NIKE FILE, POSSIBLY NIKE-TRACK-CLUB"
	end
end
puts "``````````````````````````````````````````````````````````````````````````"
puts ""

puts "================================================================================"
puts "ALL DONE!"
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

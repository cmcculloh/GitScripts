require 'fileutils'
include FileUtils

Dir.chdir("/workspaces/fl_git/nike-track-club")

status = system( "git status" )

puts status

pull = system( "git pull origin master" )

puts pull

Dir.chdir("/workspaces/fl_git/finishline/")

checkout = system( "git checkout stage" )

puts "checked out stage"

pull_stage = system( "git pull fl stage" )

puts "pulled stage"

cp_r "/workspaces/fl_git/nike-track-club/", "/workspaces/fl_git/finishline/modules/base/j2ee-apps/base/web-app.war/global/promos/nike-track-club/"

puts "copied files"

stage_status = system( "git status" )

puts stage_status

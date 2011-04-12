require 'fileutils'
include FileUtils
require 'date'
require 'time'
require 'rubygems'
require 'git'


puts <<-eot
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

DATE!!

================================================================================
eot

time = Time.new

# Components of a Time

puts "Current Time : " + time.inspect
puts time.year    # => Year of the date
puts time.month   # => Month of the date (1 to 12)
puts time.day     # => Day of the date (1 to 31 )
puts time.wday    # => 0: Day of week: 0 is Sunday
puts time.yday    # => 365: Day of year
puts time.hour    # => 23: 24-hour clock
puts time.min     # => 59
puts time.sec     # => 59
puts time.usec    # => 999999: microseconds
puts time.zone    # => "UTC": timezone name

time = Time.new

puts time.to_s
puts time.ctime
puts time.localtime
puts time.strftime("%Y-%m-%d %H:%M:%S")

newPromosBranchName = "promos---" + time.strftime("%Y-%m-%d---%A")

puts newPromosBranchName

time_now = Time.new(time.year, time.month, time.day)       # => Sat Jan 01 00:00:00 UTC 2000
time_tomorrow =  (time_now + (60 * 60 * 24 * 1))
time_yesterday = (time_now - (60 * 60 * 24 * 1))
date_today = time_now
date_tomorrow = time_tomorrow
date_yesterday = time_yesterday

puts "today: " + (date_today.strftime("%Y-%m-%d"))
puts "tomorrow: " + (date_tomorrow.strftime("%Y-%m-%d"))
puts "yesterday: " + (date_yesterday.strftime("%Y-%m-%d"))

aFileName = ("D:\\workspaces\\helios_workspace\\builds\\build\\front-end\\meta\\branch-lists\\a_test_" + newPromosBranchName + ".txt")
aFile = File.new(aFileName, "w+")
if aFile
	aFile.puts <<-eot
GIT branch to merge into fl
===========================

::::NEWBRANCHNAMENEWBRANCHNAME::::

...which depends on branches:

::::branchnames::::

i have already merged `::::NEWBRANCHNAMENEWBRANCHNAME::::` into fl/qa and fl/dev and pushed those back out.

...it is NOT merge into fl/master

Work completed
==============

- Copied files to 108, 201 &amp; /media
- Tested new files.
- Committed files to GIT
- Zipped files up and emailed to Brandon Rojas et all

eot
#

aFile.close
else
	puts "Unable to open file!"
end

aFile = File.open(aFileName, "a+")
if aFile
	text = File.read(aFile)
	text = text.gsub(/::::NEWBRANCHNAMENEWBRANCHNAME::::/, newPromosBranchName)
	aFile.close
	aFile = File.open(aFileName, "w+")
	if aFile
	aFile.puts text
	aFile.close
	else
		puts "Unable to open file!"
	end
else
	puts "Unable to open file!"
end

theStatus = system( "ls" )
puts theStatus

whereami = system( "cd" )

puts whereami



puts ""
puts ".........................................................................."
puts "moving into right repo"
Dir.chdir("d:\\workspaces\\helios_workspace\\finishline")
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


Dir.chdir("/workspaces/fl_git/finishline")
#Dir.chdir("/opt/jboss/server/04finishline/deploy")

require 'grit'
require 'net/smtp'
include Grit

repo = Repo.new("/workspaces/fl_git/finishline")
#repo = Repo.new("/opt/jboss/server/04finishline/deploy")

status = repo.git.method_missing("status")

regex = Regexp.new(/nothing to commit \(working directory clean\)/);
matchdata = regex.match(status)

def send_email(from, from_alias, to, to_alias, subject, message)
	msg = <<END_OF_MESSAGE
From: #{from_alias} <#{from}>
To: #{to_alias} <#{to}>
Subject: #{subject}

#{message}
END_OF_MESSAGE

	Net::SMTP.start('localhost') do |smtp|
		smtp.send_message msg, from, to
	end
end

if matchdata
	puts "everything looks good"
	send_email("102", "102", "Christopher McCulloh", "cmcculloh@finishline.com", "Nike Track Club Unchanged", status)
else
	puts status
	send_email("102", "102", "Christopher McCulloh", "cmcculloh@finishline.com", "Nike Track Club has changed", status)
end
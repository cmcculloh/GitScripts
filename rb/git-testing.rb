require 'rubygems'
require 'git'



# workspace specific
development_dir = "D:" # ubuntu: /media/Development
workspaces_name = "workspaces"
workspace_name = "helios_workspace"
main_project_name = "finishline"
builds_project_name = "builds"
media_project_name = "finishline_media"


development_root = development_dir + "/"

workspaces_dir = development_root + workspaces_name
workspaces_root = workspaces_dir + "/"

workspace_dir = workspaces_root + workspace_name
workspace_root = workspace_dir + "/"

main_project_dir = workspace_root + main_project_name
main_project_root = main_project_dir + "/"

builds_project_dir = workspace_root + builds_project_name
builds_project_root = builds_project_dir + "/"

media_project_dir = workspace_root + media_project_name
media_project_root = media_project_dir + "/"



# fe0c621a7b5c16211f5a6e0c02e521f1d81afa63


working_dir = Dir.getwd

puts "working_dir: " + working_dir
puts "main_project_dir: " + main_project_dir

g = Git.open (main_project_dir)

puts g.index
puts g.index.readable?
puts g.index.writable?
puts g.repo
puts g.dir


commit = g.gcommit('fe0c621a7b5c1621')

puts commit.gtree
puts commit.parent.sha
puts commit.parents.size
puts commit.author.name
puts commit.author.email
puts commit.author.date.strftime("%m-%d-%y")
puts commit.committer.name
puts commit.date.strftime("%m-%d-%y")
puts commit.message

#puts g.revparse('v2.5:Makefile')

#puts g.branches # returns Git::Branch objects
g.branches.local
branches = g.branches.local
puts ""
puts branches
puts ""
puts "and"
puts ""
puts ""
puts branches
puts ""
puts "and"
puts ""
puts ""
puts branches
puts ""
puts "and"
puts ""

#puts g.branches.remote
#puts g.branches[:master].gcommit
#puts g.branches['origin/master'].gcommit


#puts g.log.since('2 weeks ago').each {|l| puts l.sha }
#puts g.log   # returns array of Git::Commit objects
#puts g.log.since('2 weeks ago')
#puts g.log.each {|l| puts l.sha }



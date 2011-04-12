require 'rubygems'
require 'grit'
include Grit
Grit.debug
#Grit.use_pure_ruby

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


repo = Repo.new(main_project_dir)

puts "Commit Log"

myCommits = repo.commits('master')

puts myCommits


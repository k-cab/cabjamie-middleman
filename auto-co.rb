#!/usr/bin/env ruby

# synchronise folder with a git repository.

require 'date'

branch = 'dropbox'

codebases = [
	'.',
	'source/mackerel-chrome'
]

date = Date.today

add_cmd = "git add *"
commit_cmd = "git commit -a -m 'dropbox change on #{date}'"
push_cmd = "git push origin #{branch}"

def callsys dir, *cmds
	cmd_strs = cmds.map { |cmd| cmd + "; " }
	p "## (#{dir}) #{cmd_strs}"
	system "cd #{dir}; #{cmd_strs}"
end

codebases.map do |codebase|
	callsys codebase, add_cmd, commit_cmd
end

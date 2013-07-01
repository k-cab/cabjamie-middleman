#!/usr/bin/env ruby

# synchronise folder with a git repository.

require 'date'
require 'git'
require 'logger'
require 'pp'


branch = 'dropbox'

@codebases = [
	'.',
	'source/mackerel-chrome'
]

date = Date.today

# pull_cmd = "git pull origin develop"
@add_cmd = "git add %files%"
commit_cmd = "git commit -a -m 'dropbox change on #{date}'"
push_cmd = "git push origin #{branch}"


doit = -> {
	# execute all the commands

	@codebases.map do |codebase|
		p "** adding/committing #{codebase}"
		callsys codebase, *add_cmd_files(codebase), commit_cmd, push_cmd
	end	
}


def callsys dir, *cmds
	# cmd_strs = cmds.map { |cmd| cmd + "; " }
	cmds.map do |cmd|
		pp "* cmd: (#{dir}) #{cmd}"
		system "cd #{dir}; #{cmd}"		
	end
end


def add_cmd_files codebase
	g = Git.open( codebase, :log => Logger.new(STDOUT))
	untracked = g.status.untracked.keys

	# filter out submodules
	submodules = @codebases.reject { |e| [ '.', codebase ].include? e }
	unless submodules.empty?
		submodule_pattern = submodules.join '|'
		untracked = untracked.reject { |e| e =~ /^#{submodule_pattern}/ }
	end

	untracked.map { |e| @add_cmd.gsub '%files%', "'#{e}'" }
end



doit.call

# test

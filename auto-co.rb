#!/usr/bin/env ruby

# synchronise folder with a git repository.

require 'date'

source = '.'
git_url = 'https://sohocoke@bitbucket.org/sohocoke/bbl-middleman.git'
branch = 'dropbox'

date = Date.today

add_cmd = "git add *"
commit_cmd = "git commit -a -m 'dropbox change on #{date}'"

def callsys cmd
	p "## #{cmd}"
	system cmd
end


callsys add_cmd
callsys commit_cmd

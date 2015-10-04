# TODO  grep -r '<<<<<<<' to check for merge conflicts.


require 'rake'
require 'rake/packagetask'


site_name = "cabjamie"

task :default => :loop

task :release => [ :stage, :'deploy:github', :'tag' ]

task :stage => [ :build, :'deploy:bbl-rails' ]

desc 'dev loop'
task :loop do
	sh %q(
		bundle exec middleman
	)
end

desc 'build everything'
task build: [:'build:middleman']

desc 'run the the middleman build'
task :'build:middleman' do
	cmd = %q(
		set -e

		bundle exec middleman build

		# TODO failure handling
	)

	system cmd
end

namespace :deploy do

	desc "staging deployment (Heroku)"
	task :'bbl-rails' do
		cmd = '''
			echo "commit and push bbl-rails to heroku"
  		rsync -av build/* ../bbl-rails/public/
  		cd ../bbl-rails
			git ci -a -m "prepare bbl-middleman staging."
			git push heroku
		'''

		system cmd
	end

	desc "production deployment (Github Pages)"
	task :'github' do
		sh """
			rsync -av --delete build/* ./#{site_name}.github.io/
			cd ./#{site_name}.github.io/
			git add *
			git commit -a -m 'built from bbl-middleman at #{Time.new}'
			git push
		"""
	end
	
end


desc 'watch and deploy in a loop'
task :'deploy:loop' do
	cmd = %q(
		while [ 0 ]; do rake deploy; sleep 20; done
		)

	system cmd
end

desc 'git tag'
task :tag	do
	sh %Q(
    git tag #{Time.new.utc.to_s.gsub(' ', '_').gsub(':', '_')}
	)	
end

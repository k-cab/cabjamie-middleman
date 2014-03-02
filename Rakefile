# TODO  grep -r '<<<<<<<' to check for merge conflicts.


require 'rake'
require 'rake/packagetask'


task :default => :loop

task :release => [ :stage, :'deploy:github', :'tag' ]

task :stage => [ :build, :'deploy:dev', :'deploy:bbl-rails' ]

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
	## grew out of:
	# bundle exec middleman build -c; rsync -avv source/mackerel-chrome/_* build/mackerel-chrome/; rsync -avv --delete build/ ~/Dropbox/bigbearlabs/builds/bbl-middleman
	
	cmd = %q(
		set -e

		bundle exec middleman build

		# copy over _* e.g. _locales to get build/mackerel-chrome to work.
		rsync -avv source/mackerel-chrome/_* build/mackerel-chrome/

		# TODO failure handling
	)

	system cmd
end

namespace :deploy do
	desc "dev deployment (Google Drive)"
	task :dev do
		cmd = '''
			rsync -avv --delete build/ "~/Google Drive/bbl-middleman" | grep -v uptodate
		'''

		system cmd
	end

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
			rsync -av --delete build/* ../bigbearlabs.github.io/
			cd ../bigbearlabs.github.io/
			git add *
			git commit -a -m 'built from bbl-middleman at #{Time.new}'
			git push
		"""
	end
	
	desc "production deployment (Gandi)"
	task :'mackerel-site' do
		cmd = %q(
			set -e

			echo "Copying build output to mackerel-site/public/..."
			rsync -av --delete build/* ~/Dropbox/bigbearlabs/ngp/mackerel/mackerel-site/public/
	
			echo "'git push gandi master'..."
			(cd ~/Dropbox/bigbearlabs/ngp/mackerel/mackerel-site/public
				git add -A :/
				git commit -a -m "site build"
				git push gandi master  # depends on the right ssh identity configured in ~/.ssh/config
				)
			
			echo "Running deploy command on gandi server via ssh..."
			ssh 482462@git.dc0.gpaas.net 'deploy default.git master'
		)

		system cmd
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
		git tag "#{Time.new.to_s}"
	)	
end


## per-project.

namespace :mackerel do
	desc 'create a zip of the chrome extension'
	task :archive do
		manifest_file = 'build/mackerel-chrome/manifest.json'

		# e.g. change line 
		# ,"version":"0.6.0"
		# to
		# ,"version":"0.6.1"
		bump = -> {
			EXPR_BUILD_NUMBER = /(.*version.*"\d\.\d\.)(\d)(")/

			content = File.read(manifest_file)
			content_to = ''
			content.each_line { |line| 
				new_line = line

				# strip comments from content
				if line =~ EXPR_BUILD_NUMBER
					new_line = line.gsub( EXPR_BUILD_NUMBER, "\\1#{$~[2].to_i + 1}\\3" )
				end

				content_to << new_line
			}

			File.open(manifest_file, "w") { |file| 
				file.puts content_to
			}

		}

		# remove comments so chrome store doens't reject.
		remove_comments = -> {
			EXPR_JS_LINE_COMMENT = /(^|\s+)\/\/.*/
			
			content = File.read(manifest_file)
			content_to = ''
			content.each_line { |line| 
				# strip comments from content
				content_to << line.gsub( EXPR_JS_LINE_COMMENT, '')
			}

			File.open(manifest_file, "w") { |file| 
				file.puts content_to
			}
		}

		zip = -> {

			zip_cmd = %q(
					zip -r build/mackerel-chrome.zip build/mackerel-chrome/
				)
			system zip_cmd

			
		  # Rake::PackageTask.new do |p|
		  #   p.need_zip = true
		  #   p.package_files.include("build/**/*")
		  # end
		}

		bump.call
		remove_comments.call
		zip.call
	end
end

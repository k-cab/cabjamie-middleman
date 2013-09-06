# TODO  grep -r '<<<<<<<' to check for merge conflicts.


require 'rake'
require 'rake/packagetask'


task :default => :build

task :deploy => [ :build, :'deploy:dev' ]


desc 'build everything'
task build: [:'build:middleman', :'build:chrome']

desc 'run the the middleman build'
task :'build:middleman' do
	## grew out of:
	# bundle exec middleman build -c; rsync -avv source/mackerel-chrome/_* build/mackerel-chrome/; rsync -avv --delete build/ ~/Dropbox/bigbearlabs/builds/bbl-middleman
	
	cmd = %q(
		bundle exec middleman build

		# copy over _* e.g. _locales
		rsync -avv source/mackerel-chrome/_* build/mackerel-chrome/

		# TODO failure handling
	)

	system cmd
end

desc 'create a zip of the chrome extension'
task :'build:chrome' do
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


namespace :deploy do
	desc "dev deployment (Dropbox)"
	task :dev do
		cmd = '''
			rsync -avv --delete build/ ~/Dropbox/bigbearlabs/builds/bbl-middleman | grep -v uptodate
		'''

		system cmd
	end

	desc "integration deployment (Heroku)"
	task :int do
		raise "unimplemented"

		cmd = '''
			echo "TODO commit and push mackerel-site to heroku"
		'''

		system cmd
	end

	desc "production deployment (Gandi)"
	task :prod do
		# TODO migrate from deploy.sh
	end
end


desc 'watch and deploy in a loop'
task :'deploy:loop' do
	cmd = %q(
		while [ 0 ]; do rake deploy; sleep 20; done
		)

	system cmd
end

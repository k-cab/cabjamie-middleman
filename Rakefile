
# bundle exec middleman build -c; rsync -av source/mackerel-chrome/_* build/mackerel-chrome/; rsync -av --delete build/ ~/Dropbox/bigbearlabs/builds/bbl-middleman


task :default => :build


task :build do
	cmd = %q(
		bundle exec middleman build -c
		rsync -av source/mackerel-chrome/_* build/mackerel-chrome/
	)

	system cmd
end

task :deploy => :build do
	cmd = %q(
		rsync -av --delete build/ ~/Dropbox/bigbearlabs/builds/bbl-middleman
	)

	system cmd
end

require 'find'
 
desc 'Compile CoffeeScript files to JavaScript'
task :iced do
  files_to_compile = []
  
  # Find the
  Dir.chdir 'js' do
    Find.find(Dir.pwd) do |path|
      if FileTest.directory? path
        if File.basename(path)[0] == ?.
          Find.prune
        else
          next
        end
      elsif path =~ /\.coffee$/
        files_to_compile << path
      end
    end
    
    `iced -c --runtime window #{files_to_compile.join(' ')}`
  end
end

desc "copy to a dropbox folder"
target_dir = "~/Dropbox/bigbearlabs/builds/mackerel-chrome"
task :deploy do
  puts "*** Deploying the extension ***"
  system "rsync -avz --exclude '.git' --delete . #{target_dir}"
end


desc "copy files from .src dirs to right place"
task :cpsrc do
  puts "*** Copying from *.src dir's ***"
  system "rsync -av styles.src/ styles/"
  system "rsync -av assets.src/ assets/"
end

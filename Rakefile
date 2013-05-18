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

target_dir = "~/Dropbox/bigbearlabs/ngp/mackerel/builds/current"
desc "copy to a dropbox folder"
task :deploy do
  puts "*** Deploying the extension ***"
  system "rsync -avz --exclude '.git' --delete . #{target_dir}"
end
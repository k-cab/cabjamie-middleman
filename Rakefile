require 'find'
 

task :default => :build
task :build => [:cpsrc, :deploy]

#=

desc "## copy to a dropbox folder"
excludes = [
  '.git',
  'Rakefile',
  '*.sublime-*',
  '*.src',
  '*.coffee',
  '*.map',
  'node_modules'
]
target_dir = "~/Dropbox/bigbearlabs/builds/mackerel-chrome"
target_dir_2 = "../mackerel-rails/public/mackerel-chrome"

exclude_opts = excludes.map{|p| "--exclude '#{p}'"}.join ' '
task :deploy do
  date = `date`.strip
  system "rm .built*; touch '.built-at-#{date}'"
  puts "*** Deploying the extension ***"
  puts "* exclude_opts: #{exclude_opts}"
  system "rsync -av --delete #{exclude_opts} . #{target_dir}"

  system "rsync -av --delete #{exclude_opts} . #{target_dir_2}"

  # system "rsync -av --delete #{target_dir_2}}" asset_dir"
end


desc "** snapshot a build for later reference"
# get the file to increment as a file.
task :snapshot => [ :increment, :build ]


# REFACTOR
# 
# @return a DurableValue
class DurableValue
  attr_reader :val

  def initialize identifier
    @identifier = identifier

    # load from filename
    if File.exists? filename
      data = File.read filename
    else
      data = ""
    end

    @val = data.to_i
  end

  def change new_val
    @val = new_val

    # TODO save out.
    File.open filename, "w" do |file|
      file.write @val.to_s
    end
  end

  def filename
    ".#{@identifier}.durable"
  end

  def save
    
  end
end


class File
  def self.current_dir
    File.new '.'
  end

  # TODO error cases
  def self.replace_content filename, token, str
    text = File.read(filename)
    text.gsub!(token, str)
    File.open(filename, "w") { |file| file.puts text }
  end

  def apply filenames_in_scope, &block
    filenames_in_scope.map do |filename|
      block.call filename
    end
  end

end

# END REFACTOR


desc "** build for chrome"
task 'build:chrome' do
  # for each directive, process files 
  # fetch remote scripts
  # maybe concatenate and minify
  # zip up
end

desc "** increment build number"
task :increment do
  # increment the version.
  build_number_durable = DurableValue.new 'build_number'
  previous_build_number = build_number_durable.val
  current_build_number = build_number_durable.val + 1
  build_number_durable.change current_build_number

  build_number_pattern = '"build_number":"%no%"'
  previous_build_number_pattern = build_number_pattern.gsub '%no%', previous_build_number.to_s
  current_build_number_pattern = build_number_pattern.gsub '%no%', current_build_number.to_s

  File.current_dir.apply [ 'manifest.json' ] do |file|
    File.replace_content file, previous_build_number_pattern, current_build_number_pattern
  end
end
 
desc "## copy files from .src dirs to right place"
task :cpsrc do
  puts "*** Copying from *.src dir's ***"
  system "rsync -av styles.src/ styles/"
  system "rsync -av assets.src/ assets/"
end

#=

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

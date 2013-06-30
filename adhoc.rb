require 'git'
require 'logger'
require 'pp'

g = Git.open( '.', :log => Logger.new(STDOUT))
pp g.status.untracked.keys

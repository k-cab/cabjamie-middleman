require 'rubygems'
require 'middleman/rack'

run Middleman.server


require 'rack/rewrite'
use Rack::Rewrite do
  # rewrite rules here
  # e.g.
  # rewrite   '/wiki/John_Trupiano',  '/john'
  # r301      '/wiki/Yair_Flicker',   '/yair'
  # r302      '/wiki/Greg_Jastrab',   '/greg'
  # r301      %r{/wiki/(\w+)_\w+},    '/$1'

  ## gandi instance not running with rack, so this is superceded by page with the meta tag.
  # r301 '/onehour/support', 'http://support.bigbearlabs.com/forums/191718-general/category/67220-onehour'
end


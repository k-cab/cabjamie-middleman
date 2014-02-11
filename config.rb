#Markdown
require 'kramdown'
set :markdown_engine, :kramdown


activate :gzip

# image optimisation
# activate :image_optim  # DISABLED very slow.

#Livereload
activate :livereload, 
  :port => 35730,
  :no_swf => true


## redirects
redirect 'blog/index.html', to:'http://blog.bigbearlabs.com'

redirect 'webbuddy/buy/index.html', to:'https://itunes.apple.com/gb/app/webbuddy/id525308400?mt=12'

redirect 'researches/staging/plugins/index.html', to:'http://bbl-rails.herokuapp.com/webbuddy-plugins/index.html'

redirect 'researches/extensions/chrome/index.html', to:'https://chrome.google.com/webstore/detail/researches-chrome-extensi/elcnecdfdhdfkpcgnejgacedngjflcha'
redirect 'research-app', to:'/researches'


## temporary redirects
redirect 'about/index.html', to:'/consulting'
redirect 'contact/index.html', to:'/consulting'

redirect 'downloads/index.html', to:'/webbuddy'

redirect 'webbuddy/2/preview/index.html', to:'http://alpha.webbuddyapp.com'


## legacy redirects involving meta tags in index.html.
## assemble redirects without layout to avoid flickering.
page "/onehour/support/*", :layout => false
page "/webbuddy/support/*", :layout => false
page "/webbuddy/start/*", :layout => false


activate :blog do |blog|
  blog.sources = "blog-test/{year}/{month}/{day}/{title}.html"
end


### 
# Compass
###

# Susy grids in Compass
# First: gem install compass-susy-plugin
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
# 
# With no layout
# page "/path/to/file.html", :layout => false
# 
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
# 
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end


# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# set :http_path, "/images"

activate :relative_assets

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css
  
  # Minify Javascript on build
  # NOTE disabling this until we make the angular workflow compatible with minification.
  # activate :minify_javascript
  
  # Create favicon/touch icon set from source/favicon_base.png
  ## NOTE disabling due to the build getting touched every time.
  activate :favicon_maker
  
  # Enable cache buster
  # activate :cache_buster
  
  # Use relative URLs
  # activate :relative_assets
  
  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher
  
  # Or use a different image path
  # set :http_path, "/Content/images/"
  # set :http_path, "/"
end




## obsolete content

## set up the mackerel-chrome subproject
page "/mackerel-chrome/*", :layout => "angular"
page "/mackerel-chrome/templates/*", :layout => false
page "/mackerel-chrome/partials/*", :layout => false
page "/mackerel-chrome/styles/*", :layout => false

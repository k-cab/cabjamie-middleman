# prerequisites:
## install xcode gcc installer
## exclude dirs .bundle, vendor, build from dropbox sync


# install rvm
curl -L https://get.rvm.io | bash -s stable

# # install brew
# bin/install_homebrew.rb

# install a ruby - will probably install macports.
rvm install 1.9.3

# install the bundle
DEBUG_RESOLVER=1 bundle install --no-deployment


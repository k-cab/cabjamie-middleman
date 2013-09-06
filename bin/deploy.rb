%q(
# password: dlafvfknxn

`dirname $0`/auto-co.rb

rake deploy
)

# scope of deployment: the build folder

# target1: public dir on bbl-rails (deployed on heroku)
INTEGRATION = '''
'''

# target2: servers on gandi.net
PRODUCTION = '''
rsync -av --delete build/* ../ngp/mackerel/mackerel-site/public/
(cd ../ngp/mackerel/mackerel-site/public
  git add -A :/
  git commit -a -m "site build"
  git push gandi master -i ~/.ssh/github_rsa
  )

ssh -i ~/.ssh/github_rsa 482462@git.dc0.gpaas.net 'deploy default.git master'
'''

task deploy do
  system INTEGRATION
end

task deploy:prod do
  system PRODUCTIOn
end

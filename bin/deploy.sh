# password: dlafvfknxn

rake deploy

rsync -av --delete build/* ../ngp/mackerel/mackerel-site/public/

(cd ../ngp/mackerel/mackerel-site/public
	git add -A :/
	git commit -a -m "site build"
	git push gandi master
	)

ssh 482462@git.dc0.gpaas.net 'deploy default.git master'


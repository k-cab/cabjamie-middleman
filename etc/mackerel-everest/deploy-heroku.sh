# merges changes from develop and pushes to heroku

git co module/mackerel-everest
git merge -s subtree develop
git push mackerel-everest-heroku module/mackerel-everest:master

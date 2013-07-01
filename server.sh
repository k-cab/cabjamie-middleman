#!/bin/sh

cd `dirname $0`

(
	sleep 7;
	open -a "Google Chrome" http://localhost:4567
) &
bundle exec 'middleman server --verbose'

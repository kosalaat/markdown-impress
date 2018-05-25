config=~/.impress-markdown-config
dir_path=$(dirname $0)

touch $config

grep TOKEN $config 2>&1 >/dev/null
[ $? -ne 0 ] && echo "TOKEN = " > $config

grep RSYNC $config 2>&1 >/dev/null
[ $? -ne 0 ] && echo "RSYNC = @echo 'No SSH credentials set. Run config.sh.'" >> $config

echo "We couldn't find a config file. Initiating config file creation."
echo
read -p "If you want to use, github Auth Token enter now [press enter to skip]: " token
[ "x$token" != "x" ] && {
	while true;
	do 
		rate=$(curl -v -H "Authorization: token $token" https://api.github.com 2>&1 | awk -F: '$1 == "< X-RateLimit-Limit" { print int($2) }')
		[ $rate -gt 1000 ] && {
			sed -i '' "s/TOKEN/TOKEN = -H \"Authorization: token ${token}\"/" $config
			break
		} || {
			read -p "Invalid token. Try again [press enter to skip]: " token
			[ "x$token" == "x" ] && break
		}
	done
}

read -p "SSH credentials to publish the presentation. e.g. webuser@impress.myweb.com:/var/www/html/ [or press enter to skip]: " uri
[ "x$uri" != "x" ] && {
	while true;
	do 
		rsync -azvr ${dir_path}/upload/css $uri	
		[ $? -eq 0 ] && {
			RSYNC=$(echo "rsync -azvr ${dir_path}/upload/* $uri" | sed 's/\//\\\//g')
			sed -i '' "s/RSYNC = @echo 'No SSH credentials set. Run config.sh./RSYNC = $RSYNC/" $config
			break
		} || {
			read -p "Invalid URI. Try again [or press enter to skip]: " uri
			[ "x$uri" == "x" ] && {
				sed -i '' "s/RSYNC/RSYNC = @echo 'No SSH credentials set. Run config.sh.'" $config
			}
		}
	done
}

ln -s $config config.mk

for x in $@
	do
		cat $x | tr -d "\r\n" | tr '[:upper:]' '[:lower:]' | egrep -o "<div class=\"listcontainer.hide-more-mobile.*<a data-page-number=\"[0-9]*\".*data-offset=\"[0-9]*\"class=\"pagenum last[^<]*</a></div></div><[^>]*><[^>]*>" | sed 's/<span class=\"ui_bubble_rating bubbl/\n&/g' | sed s/"<span class=\"ui_bubble_rating bubble_\([0-9]\)[0-9]"/\\1/ | sed 's/<div class=\"loadingshade hidden/\n&/g' | sed 's/<div class=\"mgrrspninline\">.*<\/div><\/div><\/div>//g' | sed 's/<p/\n&/g' | sed 's/\"><\/span><span class=\"ratingdate\".*<div class=\"entry\">//' | egrep -o "^[0-9]|<p class=\"partial_entry\".*</p>" | sed s/"<[^>]*>"//g | paste - - >> reviews.txt
	done



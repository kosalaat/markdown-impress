dir_path=$(dirname $0)
title=$(awk -F: "\$2==\"title\" { print \$3 }" $dir_path/metadata)

cat ${dir_path}/impress.header > ${dir_path}/upload/final.html

sed -i '' "s/:title:/$title/" ${dir_path}/upload/final.html

for html_files in $(cut -d: -f 1 metadata)
do
	fn=$html_files
	out=$(awk -F: "\$1==$fn { print  \"<div class='step' step='\"\$1\"' data-x='\"\$2\"' data-y='\"\$3\"' data-z='\"\$4\"' data-rotate-y='\"\$5\"'>\" }" $dir_path/metadata)
	[ "x$out" == "x" ] || {
		echo $out >> ${dir_path}/upload/final.html
		cat tmp/${html_files}.html >> ${dir_path}/upload/final.html
		echo "</div>" >> ${dir_path}/upload/final.html
	}
done

cat $dir_path/impress.footer >> ${dir_path}/upload/final.html 

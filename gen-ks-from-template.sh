#!/bin/sh

test -f "$1" || {
 echo "$1 not an existing  kickstart file"
 echo "Syntax: $0 <input file> <output file>"
 exit
}
test $# -lt 2 && {
 echo "output file missing"
 echo "Syntax: $0 <input file> <output file>"
 exit
}

IN_FN="$1"
OUT_FN="$2"

read -p "Your domain: " YOURDOMAIN
read -s -p "Your root password: " YOURPASSWD

sed "s/^rootpw --iscrypted.*/rootpw --iscrypted $(python -c 'import crypt; print(crypt.crypt("${YOURPASSWD}", "$6$My Salt"))')/" ${IN_FN} > ${OUT_FN}

sed -i "s/<your-domain>/${YOURDOMAIN}/g" ${OUT_FN}

echo
echo "Done. Output file ${OUT_FN} generated."

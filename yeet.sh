echo $1

#setup
mkdir $1
cd $1

#MAKE A PASSIVE FOLDER AND SAVE OUTPUT THERE
mkdir passive
cd passive

#amass enum --passive -d $1 -o amass.txt & orig
amass enum -passive -d $1 -o amass.txt -r 8.8.8.8 &
subfinder -d xsolla.com -all -o subfinder.txt &
assetfinder $1 -subs-only | grep -v '*' | tee assetfinder.txt &
curl -s https://crt.sh/?q=$1 | grep $1 | cut -d ">" -f2 | cut -d "<" -f 1 | sort -u | tee crt.txt &
sublist3r -d $1 -o sublister.txt &

wait

cd ../
cat passive/* | sort -u > passiveoutput.txt

#altdns
altdns -i passiveoutput.txt -o altdns1.txt -w ~/tools/altdns/words.txt

#massdns
~/tools/massdns/bin/massdns -r ~/tools/massdns/lists/resolvers.txt -t A -o S passiveoutput.txt -w lmao.txt
#parsemassdns
sed 's/A.*//' lmao.txt | sed 's/CN.*//' | sed 's/\..$//' | sort -u > massdns1.txt

#rm -rf lmao.txt altdns1.txt

#anadawan
altdns -i massdns1.txt -o altdns2.txt -w ~/tools/altdns/words.txt
~/tools/massdns/bin/massdns -r ~/tools/massdns/lists/resolvers.txt -t A -o S passiveoutput.txt -w lmao2.txt
sed 's/A.*//' lmao2.txt | sed 's/CN.*//' | sed 's/\..$//' | sort -u > massdns2.txt
cat massdns2.txt | grep $1 | httpx -title -status-code -o final.txt -location -content-length -no-color
#rm -rf lmao.txt altdns1.txt
mkdir trash
mv lmao.txt lmao2.txt altdns1.txt altdns2.txt massdns1.txt massdns2.txt trash

echo done
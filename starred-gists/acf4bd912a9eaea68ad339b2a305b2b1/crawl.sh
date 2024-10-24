# bash web crawler                                                                                                                                            
# $ bash crawl.sh http://example.com 

rm urls.txt
rm sub-urls.txt
rm sub-2-urls.txt

site=$1

function visit(){
    echo visiting $1

    # get URLs                                                                                                                                                
    curl -silent $1 | grep href=\" | grep "http://" | grep -o "http:\/\/[^\"]*" >> $2
}

visit $site urls.txt

while read line
do
    visit $line sub-urls.txt
done < urls.txt

while read line
do
    visit $line sub-2-urls.txt
done < sub-urls.txt
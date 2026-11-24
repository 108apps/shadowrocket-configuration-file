curl -s https://raw.githubusercontent.com/1andrevich/Re-filter-lists/main/community.lst > temp.txt
curl -s https://raw.githubusercontent.com/1andrevich/Re-filter-lists/main/domains_all.lst >> temp.txt
grep -v "mega555" temp.txt > temp2.txt
grep -v "spotify.com" temp2.txt > temp3.txt
rm temp.txt temp2.txt
echo "# NAME: domains_refilter.list" > rules/domains_refilter.list
echo "# AUTHOR: misha-tgshv" >> rules/domains_refilter.list
echo "# REPO: https://github.com/misha-tgshv/shadowrocket-configuration-file" >> rules/domains_refilter.list
echo "# UPDATED: $(TZ='Europe/Moscow' date '+%Y-%m-%d %H:%M:%S')" MSK >> rules/domains_refilter.list
echo "# SOURCE: https://github.com/1andrevich/Re-filter-lists" >> rules/domains_refilter.list
sed 's/^/DOMAIN-SUFFIX,/g' temp3.txt | tee domaintmp
wc -l < domaintmp | awk '{print "# TOTAL:", $1}' >> rules/domains_refilter.list
cat domaintmp >> rules/domains_refilter.list
rm domaintmp temp3.txt

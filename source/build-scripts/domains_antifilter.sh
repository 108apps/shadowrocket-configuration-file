curl -sSL https://community.antifilter.download/list/domains.lst \
  | sed -E 's/^\+\./DOMAIN-SUFFIX,/; s/^[^D]/DOMAIN-SUFFIX,&/' \
  | sed '/www|spotify.com/d' \
  | awk '!seen[$0]++' > temp_list.txt
echo "# Количество доменов: $(wc -l < temp_list.txt)" > rules/domains_antifilter.list
cat temp_list.txt >> rules/domains_antifilter.list
rm temp_list.txt

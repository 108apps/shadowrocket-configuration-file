curl -s https://community.antifilter.download/list/community.lst \
  | sed 's/^/IP-CIDR,/g' \
  | sort -u > temp_aips.txt
echo "# Количество IP-адресов: $(wc -l < temp_aips.txt)" > rules/ips_antifilter.list
cat temp_aips.txt >> rules/ips_antifilter.list
rm temp_aips.txt

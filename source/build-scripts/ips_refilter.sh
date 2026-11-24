curl -s https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/community_ips.lst > ips1.txt
curl -s https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/discord_ips.lst >> ips1.txt
curl -s https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/ipsum.lst >> ips1.txt
sed 's/^/IP-CIDR,/g' ips1.txt | sort -u > temp_ips.list
echo "# Количество IP-адресов: $(wc -l < temp_ips.list)" > rules/ips_refilter.list
cat temp_ips.list >> rules/ips_refilter.list
rm ips1.txt temp_ips.list

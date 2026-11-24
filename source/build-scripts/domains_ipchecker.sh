cat > /tmp/ipchecker.txt << 'EOF'
ipify.org
ifconfig.me
x5static.net
checkip.amazonaws.com
eu.2gis.com
ping.ozon.kz
EOF

sort -u /tmp/ipchecker.txt > /tmp/ipchecker_sorted.txt

{
  echo "# NAME: domains_ipchecker.list"
  echo "# AUTHOR: misha-tgshv"
  echo "# REPO: https://github.com/misha-tgshv/shadowrocket-configuration-file"
  echo "# UPDATED: $(TZ='Europe/Moscow' date '+%Y-%m-%d %H:%M:%S') MSK"
  echo "# SOURCE: manual curated list"
  echo "# TOTAL: $(wc -l < /tmp/ipchecker_sorted.txt)"
  sed 's/^/DOMAIN-SUFFIX,/' /tmp/ipchecker_sorted.txt
} > rules/domains_ipchecker.list

rm /tmp/ipchecker.txt /tmp/ipchecker_sorted.txt

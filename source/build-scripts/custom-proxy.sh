cat > /tmp/custom-proxy.txt << 'EOF'
p16-sign-va.tiktokcdn.com
p16-sign-sg.tiktokcdn.com
sf-ssp.tiktokcdn.com
cp-rp16-normal-ycru.tiktokv.com
habr.com
EOF

sort -u -o /tmp/custom-proxy.txt /tmp/custom-proxy.txt

{
  echo "# NAME: custom-proxy.list"
  echo "# AUTHOR: misha-tgshv"
  echo "# REPO: https://github.com/misha-tgshv/shadowrocket-configuration-file"
  echo "# UPDATED: $(TZ='Europe/Moscow' date '+%Y-%m-%d %H:%M:%S') MSK"
  echo "# SOURCE: manual curated list"
  echo "# TOTAL: $(wc -l < /tmp/custom-proxy.txt)"
  sed 's/^/DOMAIN-SUFFIX,/' /tmp/custom-proxy.txt
} > rules/custom-proxy.list

rm -f /tmp/custom-proxy.txt

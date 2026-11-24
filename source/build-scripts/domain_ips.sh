curl -s https://raw.githubusercontent.com/misha-tgshv/shadowrocket-configuration-file/refs/heads/main/source/domains.list > temp_domains.txt
> rules/domain_ips.list
while read domain; do
  [ -z "$domain" ] && continue
  [[ $domain =~ ^# ]] && continue
  ip=$(dig +short "$domain" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
  if [ -n "$ip" ]; then
    echo "$ip" >> rules/domain_ips.list
  fi
done < temp_domains.txt
rm temp_domains.txt

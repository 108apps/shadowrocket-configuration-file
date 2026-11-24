CONFNAME="sr_ru_whitelist.conf"
cp source/General.txt conf/General.tmp
sed -i "s|^update-url =.*|update-url = https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/conf/${CONFNAME}|" conf/General.tmp
sed -i 's|^dns-server =.*|dns-server = system|' conf/General.tmp

{
  cat conf/General.tmp
  echo "# Выборочные правила маршрутизации"
  echo "[Rule]"
  echo "RULE-SET,https://github.com/hydraponique/roscomvpn-geoip/raw/refs/heads/master/release/text/whitelist.txt,DIRECT"
  echo "RULE-SET,https://raw.githubusercontent.com/hxehex/russia-mobile-internet-whitelist/refs/heads/main/whitelist.txt,DIRECT"
  echo "FINAL,PROXY"
} > conf/${CONFNAME}

sed -i "1s/^/# @misha-tgshv, built on $(TZ=\"Asia/Novokuznetsk\" date)\n/" conf/${CONFNAME}
rm conf/General.tmp

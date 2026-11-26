CONFNAME="sr_ru_keen.conf"
cp source/General.txt conf/General.tmp
sed -i "s|^update-url =.*|update-url = https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/conf/${CONFNAME}|" conf/General.tmp

{
  cat conf/General.tmp
  echo "# Выборочные правила маршрутизации"
  echo "[Rule]"
  echo "RULE-SET,https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/YouTube/YouTube.list,PROXY"
  echo "RULE-SET,https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Instagram/Instagram.list,PROXY"
  echo "RULE-SET,https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Facebook/Facebook.list,PROXY"
  echo "RULE-SET,https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Telegram/Telegram.list,PROXY"
  echo "RULE-SET,https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Whatsapp/Whatsapp.list,PROXY"
  echo "RULE-SET,https://github.com/toneywhitez/zkeen_rules/releases/latest/download/telegram_ips.list,PROXY,no-resolve"
  echo "RULE-SET,https://github.com/toneywhitez/zkeen_rules/releases/latest/download/meta_ips.list,PROXY,no-resolve"
  echo "FINAL,DIRECT"
} > conf/${CONFNAME}

sed -i "1s/^/# @misha-tgshv, built on $(TZ=\"Asia/Novokuznetsk\" date)\n/" conf/${CONFNAME}
rm conf/General.tmp

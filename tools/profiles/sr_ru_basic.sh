CONFNAME="sr_ru_basic.conf"
cp source/General.txt conf/General.tmp
sed -i "s|^update-url =.*|update-url = https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/conf/${CONFNAME}|" conf/General.tmp

{
  cat conf/General.tmp
  echo "# Выборочные правила маршрутизации"
  echo "[Rule]"
  echo "RULE-SET,https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/rules/domains_community.list,PROXY"
  echo "RULE-SET,https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/rules/domain_ips.list,PROXY,no-resolve"
  echo "RULE-SET,https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Shadowrocket/Telegram/Telegram.list,PROXY"
  echo "RULE-SET,https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Shadowrocket/Discord/Discord.list,PROXY"
  echo "RULE-SET,https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Shadowrocket/Whatsapp/Whatsapp.list,PROXY"
  echo "RULE-SET,https://github.com/toneywhitez/zkeen_rules/releases/latest/download/telegram_ips.list,PROXY,no-resolve"
  echo "RULE-SET,https://github.com/toneywhitez/zkeen_rules/releases/latest/download/meta_ips.list,PROXY,no-resolve"
  echo "FINAL,DIRECT"
} > conf/${CONFNAME}

sed -i "1s/^/# @misha-tgshv, built on $(TZ=\"Asia/Novokuznetsk\" date)\n/" conf/${CONFNAME}
rm conf/General.tmp

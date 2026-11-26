CONFNAME="sr_ru_geo.conf"
cp source/General.txt conf/General.tmp
sed -i "s|^update-url =.*|update-url = https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/conf/${CONFNAME}|" conf/General.tmp

# Меняем комментарий только для sr_ru_geo.conf
sed -i 's|^# Опционально\. Добавьте эти адреса в настройках программы Settings → GeoLite2 Database$|# Обязательно. Добавьте эти адреса в настройках программы Settings → GeoLite2 Database|' conf/General.tmp

{
  cat conf/General.tmp
  echo "# Отправляем все сайты в ГЕО напрямую, а остальное в прокси"
  echo "[Rule]"
  echo "RULE-SET,https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/rules/custom-proxy.list,PROXY"
  echo "GEOIP,RU,DIRECT"
  echo "RULE-SET,https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/rules/domains_ipchecker.list,DIRECT"
  echo "# DOMAIN-SUFFIX,ru,DIRECT"
  echo "# DOMAIN-SUFFIX,рф,DIRECT"
  echo "# DOMAIN-SUFFIX,su,DIRECT"
  echo ""
  echo "# Final"
  echo "FINAL,PROXY"
} > conf/${CONFNAME}

# Вставляем .ru в строку skip-proxy в conf/${CONFNAME}
sed -i '/^skip-proxy/ s/$/,*.ru,*.su,*.рф/' conf/${CONFNAME}

sed -i "1s/^/# @misha-tgshv, built on $(TZ=\"Asia/Novokuznetsk\" date)\n/" conf/${CONFNAME}
rm conf/General.tmp

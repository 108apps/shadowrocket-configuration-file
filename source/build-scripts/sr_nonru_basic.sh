CONFNAME="sr_nonru_basic.conf"
cp source/General.txt conf/General.tmp
sed -i "s|^update-url =.*|update-url = https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/conf/${CONFNAME}|" conf/General.tmp

{
  cat conf/General.tmp
  echo "# Выборочные правила маршрутизации"
  echo "[Rule]"
  echo "DOMAIN-SUFFIX,ru,PROXY"
  echo "DOMAIN-SUFFIX,su,PROXY"
  echo "DOMAIN-SUFFIX,рф,PROXY"
  echo "DOMAIN-KEYWORD,.ru,PROXY"
  echo "DOMAIN-KEYWORD,.su,PROXY"
  echo "DOMAIN-KEYWORD,.рф,PROXY"
  echo "FINAL,DIRECT"
} > conf/${CONFNAME}

# Вставляем .ru в строку skip-proxy в conf/${CONFNAME}
sed -i '/^skip-proxy/ s/$/,*.ru/' conf/${CONFNAME}

sed -i "1s/^/# @misha-tgshv, built on $(TZ=\"Asia/Novokuznetsk\" date)\n/" conf/${CONFNAME}
rm conf/General.tmp

CONFNAME="sr_ru_mini.conf"
cp source/General.txt conf/General.tmp
sed -i "s|^update-url =.*|update-url = https://cdn.jsdelivr.net/gh/misha-tgshv/shadowrocket-configuration-file@main/conf/${CONFNAME}|" conf/General.tmp
{
  cat conf/General.tmp
  echo "# Выборочные правила маршрутизации"
  echo "[Rule]"
  # Проксирование портов голосовой связи
  echo "RULE-SET,https://raw.githubusercontent.com/misha-tgshv/shadowrocket-configuration-file/main/rules/voice_ports.list,PROXY"
  # Отдельное проксирование для telegram (ключевое слово)
  echo "DOMAIN-KEYWORD,telegram,PROXY"
  # Генерация доменов из community.list
  curl -s https://raw.githubusercontent.com/misha-tgshv/shadowrocket-configuration-file/main/source/community.list | \
  awk '
    BEGIN { before_youtube=1 }
    /^#/ {
      if ($0 == "# youtube") before_youtube=0
      next
    }
    NF == 0 { next }
    {
      if (before_youtube) {
        print "DOMAIN-KEYWORD," $1 ",PROXY"
      } else {
        print "DOMAIN-SUFFIX," $1 ",PROXY"
      }
    }
  '
  echo "FINAL,DIRECT"
} > conf/${CONFNAME}
sed -i "1s/^/# mini conf, @misha-tgshv, built on $(TZ=\"Asia/Novokuznetsk\" date)\\n/" conf/${CONFNAME}
sed -i '1G' conf/${CONFNAME}
rm conf/General.tmp

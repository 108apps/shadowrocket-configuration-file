CONFNAME="sr_ru_extended.conf"
cp source/General.txt conf/General.tmp

# Удаляем строку update-url, если она там есть
sed -i '/^update-url =/d' conf/General.tmp

# Закомментируем строку include = sr_ru_extended.conf
sed -i 's|^\(include = sr_ru_extended.conf\)|# \1|' conf/General.tmp

{
  cat conf/General.tmp
  echo "# Собственные правила маршрутизации"
  echo "[Rule]"
  echo ""
  echo ""
  echo ""
} > conf/${CONFNAME}

sed -i "1s/^/# @misha-tgshv, built on $(TZ=\"Asia/Novokuznetsk\" date)\n/" conf/${CONFNAME}

rm conf/General.tmp

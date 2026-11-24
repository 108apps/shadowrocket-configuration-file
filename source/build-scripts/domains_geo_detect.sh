curl -s https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-ip-geo-detect.list \
  | tr -d '\r' \
  | grep -v '^#' \
  | grep -v '^$' \
  | sed -E 's/^\+\.//' \
  | sed -E 's/^\.//' \
  | grep -v '\.ru$' \
  | sed 's/^/DOMAIN-SUFFIX,/' \
  | sort -u > temp_geo_detect.txt
{
  echo "# NAME: domains_geo_detect.list"
  echo "# AUTHOR: misha-tgshv"
  echo "# REPO: https://github.com/misha-tgshv/shadowrocket-configuration-file"
  echo "# UPDATED: $(TZ='Europe/Moscow' date '+%Y-%m-%d %H:%M:%S') MSK"
  echo "# SOURCE: https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-ip-geo-detect.list"
  echo "# Количество доменов: $(wc -l < temp_geo_detect.txt)"
  cat temp_geo_detect.txt
} > rules/domains_geo_detect.list
rm temp_geo_detect.txt

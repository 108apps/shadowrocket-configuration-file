cat > /tmp/decode_idn.py << 'PYEOF'
import sys, urllib.parse
for line in sys.stdin:
    line = line.strip().lower()
    if not line:
        continue
    try:
        decoded = urllib.parse.unquote(line)
        parts = decoded.split('.')
        has_cyrillic = any(ord(c) > 127 for p in parts for c in p)
        encoded_parts = [
            p.encode('idna').decode('ascii') if any(ord(c) > 127 for c in p) else p
            for p in parts
        ]
        punycode = '.'.join(encoded_parts)
        if has_cyrillic:
            print(f"{punycode} # {decoded}")
        else:
            print(punycode)
    except Exception:
        print(line)
PYEOF

curl -s https://www.cbr.ru/banking_sector/credit/cowebsites/ | \
grep -oP 'href="\K[^"]+' | \
grep -E '^https?://' | \
sed -E 's~https?://~~' | \
sed -E 's~/.*~~' | \
tr '[:upper:]' '[:lower:]' | \
sed -E 's/^www\.//' | \
grep -E '^[a-zA-Z0-9%._-]+\.[a-zA-Z0-9%_-]+$' | \
grep -vE '(t\.me|vk\.com|ok\.ru|telegram|dzen|twitter|youtube|zen\.yandex|rutube|linkedin|play\.google|apps\.apple|appgallery|market\.yandex|max\.ru)' | \
python3 /tmp/decode_idn.py | \
sort -u > /tmp/temp_banking.txt

{
  echo "# NAME: domains_banking.list"
  echo "# AUTHOR: misha-tgshv"
  echo "# REPO: https://github.com/misha-tgshv/shadowrocket-configuration-file"
  echo "# UPDATED: $(TZ='Europe/Moscow' date '+%Y-%m-%d %H:%M:%S') MSK"
  echo "# SOURCE: https://www.cbr.ru/banking_sector/credit/cowebsites/"
  echo "# TOTAL: $(grep -c '^' /tmp/temp_banking.txt)"
  awk '{
    if ($2) print "DOMAIN-SUFFIX," $1 " " $2 " " $3
    else print "DOMAIN-SUFFIX," $1
  }' /tmp/temp_banking.txt
} > rules/domains_banking.list

rm /tmp/decode_idn.py /tmp/temp_banking.txt

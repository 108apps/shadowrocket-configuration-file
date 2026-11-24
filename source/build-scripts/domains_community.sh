curl -s https://raw.githubusercontent.com/misha-tgshv/shadowrocket-configuration-file/main/source/community.list | \
tr -d '\r' | \
awk '
  BEGIN {
    print "# NAME: domains_community.list";
    print "# AUTHOR: misha-tgshv";
    print "# REPO: https://github.com/misha-tgshv/shadowrocket-configuration-file";
    print "# UPDATED: " strftime("%Y-%m-%d %H:%M:%S", systime(), 1) " MSK";
    print "# SOURCE: https://github.com/misha-tgshv/shadowrocket-configuration-file/blob/main/rules/domains_community.list";
    before_youtube=1
  }
  /^#/ {
    print;
    if ($0 == "# youtube") { before_youtube=0 }
    next
  }
  NF == 0 { next }
  {
    if (before_youtube) {
      print "DOMAIN-KEYWORD," $0
    } else {
      print "DOMAIN-SUFFIX," $0
    }
  }
' > rules/domains_community.list

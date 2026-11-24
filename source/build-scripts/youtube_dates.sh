YT_MODULE_DATE=$(curl -s "https://api.github.com/repos/YanbingJiang/Shadowrocket_diy_rules/commits?path=Modules/YT-Premium-V1.module&page=1&per_page=1" | jq -r '.[0].commit.committer.date' | cut -d'T' -f1)
YT_SCRIPT_DATE=$(curl -s "https://api.github.com/repos/Maasea/sgmodule/commits?path=Script/Youtube/youtube.response.js&page=1&per_page=1" | jq -r '.[0].commit.committer.date' | cut -d'T' -f1)
echo "YT_MODULE_DATE=$YT_MODULE_DATE" >> $GITHUB_ENV
echo "YT_SCRIPT_DATE=$YT_SCRIPT_DATE" >> $GITHUB_ENV

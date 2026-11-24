curl -sSL "https://raw.githubusercontent.com/Maasea/sgmodule/refs/heads/master/Script/Youtube/youtube.response.js" > temp.txt
sed 's/;e!/;e/g' temp.txt > scripts/rewrite.youtube.response.preview.js
rm temp.txt

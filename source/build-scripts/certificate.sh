mkdir -p modules
cat > modules/Certificate.module << 'EOF'
#!name=Certificate Module
[MITM]
enable=true
ca-passphrase=${CA_PASSPHRASE}
ca-p12=${CA_P12}
EOF

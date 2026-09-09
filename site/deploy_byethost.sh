#!/bin/bash
# Deploy AI Tools website to Byethost via FTP
# Usage: bash deploy_byethost.sh
set -e

SITE_DIR="$(dirname "$0")"
FTP_HOST="ftp.byethost6.com"
FTP_USER="b6_42870140"
FTP_PASS="Harrabiiyed008"
REMOTE_DIR="/public_html"

echo "============================================"
echo "  Deploy AI Tools Site to Byethost"
echo "============================================"
echo ""

# Check lftp
if ! command -v lftp &> /dev/null; then
  echo "[!] lftp not found. Install with: sudo apt install lftp"
  echo "[!] Or use FileZilla to upload site/ contents to /public_html"
  exit 1
fi

echo "[1/3] Uploading site files..."
lftp -u "$FTP_USER","FTP_PASS" "$FTP_HOST" <<EOF
set ssl:verify-certificate no
set ftp:passive-mode yes
mirror --reverse --verbose --delete \
  --exclude .git/ \
  --exclude README_DEPLOY.txt \
  --exclude deploy_byethost.sh \
  "$SITE_DIR/" "$REMOTE_DIR/"
bye
EOF

echo ""
echo "[2/3] Setting permissions..."
lftp -u "$FTP_USER","FTP_PASS" "$FTP_HOST" <<EOF
set ssl:verify-certificate no
set ftp:passive-mode yes
chmod 644 "$REMOTE_DIR/index.html"
chmod 644 "$REMOTE_DIR/style.css"
chmod 644 "$REMOTE_DIR/app.js"
chmod 644 "$REMOTE_DIR/version.json"
chmod 644 "$REMOTE_DIR/.htaccess"
chmod 644 "$REMOTE_DIR/download.php"
chmod 755 "$REMOTE_DIR/assets/"
chmod 644 "$REMOTE_DIR/assets/icon.svg"
bye
EOF

echo ""
echo "[3/3] Testing..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://aiunlimited.byethost6.com/version.json" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "  version.json: HTTP $HTTP_CODE - OK"
else
  echo "  version.json: HTTP $HTTP_CODE - may need a moment to propagate"
fi

echo ""
echo "============================================"
echo "  Deploy complete!"
echo "  Site: http://aiunlimited.byethost6.com"
echo "============================================"
echo ""
echo "NEXT STEPS:"
echo "1. Visit http://aiunlimited.byethost6.com to verify"
echo "2. Create GitHub repo and push:"
echo "   cd \"$(dirname "$SITE_DIR")\""
echo "   gh repo create ai-tools --public --source=. --remote=origin --push"
echo "3. Create release with APK + Linux tar.gz + Windows source"
echo "4. Change Byethost MySQL password in cPanel"

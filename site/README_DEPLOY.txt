============================================
  AI Tools - Deploy Guide for Byethost
  Site: http://aiunlimited.byethost6.com
============================================

PREREQUISITES
=============
1. Install lftp: sudo apt install lftp
2. You need: FTP creds (already have), MySQL creds (need password from cPanel)

STEP 1: DEPLOY WEBSITE TO BYETHOST
====================================
Option A - Automated (recommended):
  chmod +x deploy_byethost.sh
  bash deploy_byethost.sh

Option B - Manual via FileZilla:
  1. Download FileZilla: https://filezilla-project.org
  2. Host: ftp.byethost6.com
     User: b6_42870140
     Pass: Harrabiiyed008
  3. Connect -> drag all files from site/ to /public_html/
  4. Delete any old files in /public_html/ first

Option C - cPanel File Manager:
  1. Go to cpanel.byethost6.com -> Login
  2. File Manager -> /public_html
  3. Upload all files from site/ folder
  4. Extract if zipped

STEP 2: SETUP MYSQL DATABASE (optional, for counters)
======================================================
1. Login: cpanel.byethost6.com
2. MySQL Databases -> Create database: b6_42870140_ai_tools
3. Add user to database with ALL PRIVILEGES
4. Open phpMyAdmin -> run this SQL:

CREATE TABLE downloads (
  id INT AUTO_INCREMENT PRIMARY KEY,
  os VARCHAR(20) NOT NULL UNIQUE,
  count INT DEFAULT 0
);
INSERT INTO downloads (os, count) VALUES ('windows', 0), ('linux', 0), ('android', 0);

5. Edit download.php -> set $DB_PASS to your MySQL password

STEP 3: CREATE GITHUB REPO + RELEASES
========================================
1. Create account at github.com (if not already)
2. Install GitHub CLI or use web interface:
   https://github.com/new
   - Name: ai-tools
   - Public
   - Don't initialize (we have code)

3. Push code:
   cd "/home/iyed/Desktop/ai tools"
   git config user.name "Harrabiiyed"
   git config user.email "your-email@users.noreply.github.com"
   git remote add origin https://github.com/YOUR_USERNAME/ai-tools.git
   git push -u origin master

4. Create GitHub Release:
   https://github.com/YOUR_USERNAME/ai-tools/releases/new
   - Tag: v1.0.1+2
   - Title: AI Tools v1.0.1
   - Upload these files:
     * dist/v1.0.1+2/AI_Tools_v1.0.1+2_arm64-release.apk (24MB)
     * dist/v1.0.1+2/AI_Tools_v1.0.1+2_armeabi-v7a-release.apk (22MB)
     * dist/v1.0.1+2/AI_Tools_Kali_Linux_x64_release.tar.gz (12MB)
   - Publish release

5. Update version.json with actual GitHub release URLs:
   Edit site/version.json -> replace YOUR_USERNAME with your GitHub username

STEP 4: WINDOWS EXE BUILD (via GitHub Actions)
================================================
After pushing to GitHub, the workflow will auto-build:
- .github/workflows/build.yml triggers on push to main
- Downloads: build/windows/x64/runner/Release/ai_tools.exe
- Upload to same GitHub Release as .zip

STEP 5: CHANGE DEFAULT PASSWORDS
===================================
URGENT: Change these in cPanel -> Change Password:
- cPanel password (b6_42870140)
- MySQL password (b6_42870140)
- FTP password (b6_42870140)

Files created in site/:
  index.html      - Download page (auto-detects OS)
  style.css       - Dark theme responsive design
  app.js          - OS detection, version check, counters
  version.json    - Version info + GitHub URLs (update after release)
  download.php    - Counter + redirect to GitHub
  .htaccess       - MIME types + security
  assets/icon.svg - AI Tools logo

Site features:
  - Auto-detects Windows/Linux/Android
  - Shows recommended card for your OS
  - Download counters (MySQL or JSON fallback)
  - version.json for in-app update checks
  - Dark responsive design matching the app
  - Hosts binaries on GitHub (bypasses Byethost 10MB limit)

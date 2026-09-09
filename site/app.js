(function(){
  'use strict';

  const VERSION_JSON_URL = 'version.json';
  const COUNTER_API = 'download.php';

  // Detect OS
  function detectOS() {
    const u = navigator.userAgent;
    if (u.indexOf('Win') > -1) return 'windows';
    if (u.indexOf('Linux') > -1 && u.indexOf('Android') === -1) return 'linux';
    if (u.indexOf('Android') > -1) return 'android';
    if (u.indexOf('Mac') > -1) return 'linux';
    return 'unknown';
  }

  // Format file size
  function formatSize(bytes) {
    if (!bytes) return '';
    if (bytes < 1024*1024) return (bytes/1024).toFixed(0) + ' KB';
    if (bytes < 1024*1024*1024) return (bytes/(1024*1024)).toFixed(0) + ' MB';
    return (bytes/(1024*1024*1024)).toFixed(1) + ' GB';
  }

  // Set hero button
  function setHeroOS(os) {
    const el = document.getElementById('hero-os');
    if (!el) return;
    const names = {windows:'Windows',linux:'Linux',android:'Android'};
    el.textContent = names[os] || 'your platform';
  }

  // Load version.json
  async function loadVersion() {
    try {
      const r = await fetch(VERSION_JSON_URL + '?t=' + Date.now());
      if (!r.ok) return;
      const v = await r.json();

      // Version badge
      const badge = document.getElementById('version-badge');
      if (badge && v.version) badge.textContent = 'v' + v.version;

      // File sizes
      if (v.files) {
        v.files.forEach(f => {
          const sizeEl = document.getElementById(f.os + '-size');
          if (sizeEl && f.size) sizeEl.textContent = '~' + formatSize(f.size);
        });
      }
    } catch(e) {}
  }

  // Load download counts
  async function loadCounts() {
    try {
      const r = await fetch(COUNTER_API + '?action=count');
      if (!r.ok) return;
      const d = await r.json();
      if (d.windows !== undefined) document.getElementById('dl-windows').textContent = d.windows;
      if (d.linux !== undefined) document.getElementById('dl-linux').textContent = d.linux;
      if (d.android !== undefined) document.getElementById('dl-android').textContent = d.android;
    } catch(e) {}
  }

  // Track download (fire and forget)
  window.trackDownload = function(os) {
    try {
      navigator.sendBeacon(COUNTER_API + '?action=track&os=' + os);
    } catch(e) {
      fetch(COUNTER_API + '?action=track&os=' + os);
    }
  };

  // Init
  const os = detectOS();
  setHeroOS(os);
  loadVersion();
  loadCounts();

  // Highlight recommended card
  document.querySelectorAll('.download-card').forEach(card => {
    if (card.dataset.os === os) {
      card.classList.add('featured');
    }
  });
})();

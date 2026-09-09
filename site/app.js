(function(){
  'use strict';

  // ===== THEME TOGGLE =====
  const savedTheme = localStorage.getItem('theme') || 'dark';
  document.documentElement.setAttribute('data-theme', savedTheme);

  window.toggleTheme = function(){
    const cur = document.documentElement.getAttribute('data-theme');
    const next = cur === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
    const btn = document.getElementById('theme-icon');
    if(btn) btn.textContent = next === 'dark' ? '🌙' : '☀️';
  };

  // ===== LANGUAGE SYSTEM =====
  let translations = {};
  let currentLang = localStorage.getItem('lang') || 'en';

  function applyLang(lang) {
    currentLang = lang;
    localStorage.setItem('lang', lang);
    const dir = (lang === 'ar') ? 'rtl' : 'ltr';
    document.documentElement.setAttribute('dir', dir);
    document.documentElement.setAttribute('lang', lang);

    if (!translations[lang]) return;
    const t = translations[lang];

    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (t[key]) el.textContent = t[key];
    });
    document.querySelectorAll('[data-i18n-ph]').forEach(el => {
      const key = el.getAttribute('data-i18n-ph');
      if (t[key]) el.setAttribute('placeholder', t[key]);
    });
    document.querySelectorAll('[data-i18n-html]').forEach(el => {
      const key = el.getAttribute('data-i18n-html');
      if (t[key]) el.innerHTML = t[key];
    });

    // Update lang button label
    const langLabel = document.getElementById('lang-label');
    if(langLabel) langLabel.textContent = lang.toUpperCase();
  }

  window.setLang = function(lang) {
    applyLang(lang);
    document.getElementById('lang-menu').classList.remove('show');
    document.querySelectorAll('.lang-menu button').forEach(b => {
      b.classList.toggle('active', b.dataset.lang === lang);
    });
  };

  window.toggleLangMenu = function() {
    document.getElementById('lang-menu').classList.toggle('show');
  };

  // Close lang menu on outside click
  document.addEventListener('click', function(e) {
    if (!e.target.closest('.lang-select')) {
      const m = document.getElementById('lang-menu');
      if(m) m.classList.remove('show');
    }
  });

  // ===== RIPPLE EFFECT ON BUTTONS =====
  document.addEventListener('click', function(e) {
    const btn = e.target.closest('.btn, .btn-submit, .btn-download');
    if (!btn) return;
    const ripple = document.createElement('span');
    ripple.className = 'ripple';
    const rect = btn.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    ripple.style.width = ripple.style.height = size + 'px';
    ripple.style.left = (e.clientX - rect.left - size / 2) + 'px';
    ripple.style.top = (e.clientY - rect.top - size / 2) + 'px';
    btn.appendChild(ripple);
    setTimeout(() => ripple.remove(), 700);
  });

  // ===== SCROLL REVEAL ANIMATIONS =====
  function initReveal() {
    document.querySelectorAll('.feature-card, .download-card, .review-card, .bug-card, .write-panel').forEach((el, i) => {
      el.classList.add('reveal');
      el.classList.add('reveal-delay-' + ((i % 3) + 1));
    });

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

    document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
  }

  // ===== DOWNLOAD COUNTS =====
  function loadCounts() {
    fetch('download.php?action=count&t=' + Date.now())
      .then(r => r.json())
      .then(d => {
        const el = id => document.getElementById(id);
        if(el('dl-windows')) el('dl-windows').textContent = d.windows || 0;
        if(el('dl-linux')) el('dl-linux').textContent = d.linux || 0;
        if(el('dl-android')) el('dl-android').textContent = d.android || 0;
        if(el('total-downloads')) el('total-downloads').textContent = (d.windows||0)+(d.linux||0)+(d.android||0);
      })
      .catch(() => {});
  }
  loadCounts();
  setInterval(loadCounts, 15000);

  // ===== TABS (community page) =====
  window.showSection = function(name, btn) {
    document.querySelectorAll('.section-nav button').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    document.querySelectorAll('.comm-section').forEach(s => s.classList.remove('active'));
    const sec = document.getElementById('sec-' + name);
    if(sec) sec.classList.add('active');
  };

  // ===== STAR RATING =====
  var selRating = 5;
  var stars = document.querySelectorAll('#stars-in .s');
  function setStars(n) { selRating = n; stars.forEach(s => s.classList.toggle('on', parseInt(s.dataset.v) <= n)); }
  stars.forEach(s => { s.onclick = () => setStars(parseInt(s.dataset.v)); });
  setStars(5);

  // ===== COMMUNITY DATA =====
  var allReviews = [], allBugs = [];
  var avatarColors = ['avatar-a','avatar-b','avatar-c','avatar-d','avatar-e'];

  function starsHTML(n) { return '&#9733;'.repeat(n) + '&#9734;'.repeat(5 - n); }
  function timeAgo(d) {
    var diff = (Date.now() - new Date(d).getTime()) / 1000;
    if (diff < 60) return 'now'; if (diff < 3600) return Math.floor(diff / 60) + 'm';
    if (diff < 86400) return Math.floor(diff / 3600) + 'h'; return Math.floor(diff / 86400) + 'd';
  }

  function loadReviews() {
    fetch('api.php?type=reviews&action=list&t=' + Date.now())
      .then(r => r.json()).then(d => {
        allReviews = d.items || [];
        var rc = document.getElementById('review-count');
        var ra = document.getElementById('review-avg');
        if(rc) rc.textContent = allReviews.length + ' ' + (translations[currentLang]||translations.en).comm_reviews_count;
        if(ra && allReviews.length) {
          var avg = allReviews.reduce((s, r) => s + (r.rating || 5), 0) / allReviews.length;
          ra.textContent = avg.toFixed(1);
        }
        renderReviews(allReviews);
      });
  }

  function renderReviews(items) {
    var el = document.getElementById('reviews-list');
    if (!el) return;
    if (!items.length) { el.innerHTML = '<div class="empty-state"><div class="icon">&#9733;</div><p>' + ((translations[currentLang]||translations.en).comm_empty_reviews) + '</p></div>'; return; }
    el.innerHTML = items.map((r, i) => {
      var c = avatarColors[i % avatarColors.length];
      return '<div class="review-card">' +
        '<div class="review-top">' +
        '<div class="review-avatar ' + c + '">' + r.name.charAt(0).toUpperCase() + '</div>' +
        '<div class="review-info">' +
        '<div><span class="review-name">' + r.name + '</span><span class="review-platform">' + (r.platform || '') + '</span></div>' +
        '<div class="review-stars">' + starsHTML(r.rating || 5) + '</div>' +
        '</div>' +
        '<div class="review-date">' + timeAgo(r.date) + '</div>' +
        '</div>' +
        '<div class="review-text">' + r.message + '</div>' +
        '</div>';
    }).join('');
    initReveal();
  }

  window.filterReviews = function(f, btn) {
    document.querySelectorAll('#sec-reviews .filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    if (f === 'all') return renderReviews(allReviews);
    if (f === 'low') return renderReviews(allReviews.filter(r => (r.rating || 5) <= 2));
    renderReviews(allReviews.filter(r => String(r.rating || 5) === f));
  };

  function loadBugs() {
    fetch('api.php?type=bugs&action=list&t=' + Date.now())
      .then(r => r.json()).then(d => {
        allBugs = d.items || [];
        var bc = document.getElementById('bug-count');
        var bo = document.getElementById('bug-open-count');
        if(bc) bc.textContent = allBugs.length + ' ' + (translations[currentLang]||translations.en).comm_bugs_count;
        if(bo) bo.textContent = allBugs.filter(b => b.status !== 'fixed').length + ' ' + (translations[currentLang]||translations.en).comm_bugs_open;
        renderBugs(allBugs);
      });
  }

  function renderBugs(items) {
    var el = document.getElementById('bugs-list');
    if (!el) return;
    if (!items.length) { el.innerHTML = '<div class="empty-state"><div class="icon">&#9889;</div><p>' + ((translations[currentLang]||translations.en).comm_empty_bugs) + '</p></div>'; return; }
    el.innerHTML = items.map(b => {
      var dot = 'dot-' + b.severity;
      var labelClass = 'label-' + (b.status || 'new');
      return '<div class="bug-card">' +
        '<div class="bug-icon bug-open">&#9889;</div>' +
        '<div class="bug-body">' +
        '<div class="bug-title">' + b.title + '</div>' +
        '<div class="bug-meta">' +
        '<span><span class="severity-dot ' + dot + '"></span>' + b.severity + '</span>' +
        '<span>' + b.name + '</span>' +
        '<span>' + (b.platform || '') + (b.version ? ' v' + b.version : '') + '</span>' +
        '<span>' + timeAgo(b.date) + '</span>' +
        '<span class="bug-label ' + labelClass + '">' + (b.status || 'new') + '</span>' +
        '</div>' +
        '<div class="bug-desc">' + b.message + '</div>' +
        (b.steps ? '<div class="bug-steps"><strong>' + ((translations[currentLang]||translations.en).comm_steps_label) + '</strong><pre>' + b.steps + '</pre></div>' : '') +
        '</div></div>';
    }).join('');
    initReveal();
  }

  window.filterBugs = function(f, btn) {
    document.querySelectorAll('#sec-bugs .filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    if (f === 'all') return renderBugs(allBugs);
    renderBugs(allBugs.filter(b => b.severity === f));
  };

  // ===== FORM SUBMISSIONS =====
  var reviewForm = document.getElementById('review-form');
  if (reviewForm) {
    reviewForm.onsubmit = function(e) {
      e.preventDefault();
      var btn = document.getElementById('r-btn');
      btn.disabled = true; btn.textContent = '...';
      fetch('api.php?type=reviews', { method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ name: document.getElementById('r-name').value, message: document.getElementById('r-msg').value, rating: selRating, platform: document.getElementById('r-platform').value })
      }).then(r => r.json()).then(d => {
        var m = document.getElementById('r-msg-box');
        if (d.success) { m.className = 'form-msg ok'; m.textContent = '✓'; this.reset(); setStars(5); loadReviews();
          setTimeout(() => showSection('reviews', document.querySelector('.section-nav button')), 1200);
        } else { m.className = 'form-msg err'; m.textContent = d.error || 'Failed'; }
        btn.disabled = false; btn.textContent = (translations[currentLang]||translations.en).comm_submit_review;
      }).catch(() => { btn.disabled = false; btn.textContent = (translations[currentLang]||translations.en).comm_submit_review; });
    };
  }

  var bugForm = document.getElementById('bug-form');
  if (bugForm) {
    bugForm.onsubmit = function(e) {
      e.preventDefault();
      var btn = document.getElementById('b-btn');
      btn.disabled = true; btn.textContent = '...';
      fetch('api.php?type=bugs', { method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ name: document.getElementById('b-name').value, message: document.getElementById('b-msg').value, title: document.getElementById('b-title').value,
          platform: document.getElementById('b-platform').value, version: document.getElementById('b-version').value, severity: document.getElementById('b-severity').value, steps: document.getElementById('b-steps').value })
      }).then(r => r.json()).then(d => {
        var m = document.getElementById('b-msg-box');
        if (d.success) { m.className = 'form-msg ok'; m.textContent = '✓'; this.reset(); loadBugs();
          setTimeout(() => showSection('bugs', document.querySelector('.section-nav button')), 1200);
        } else { m.className = 'form-msg err'; m.textContent = d.error || 'Failed'; }
        btn.disabled = false; btn.textContent = (translations[currentLang]||translations.en).comm_submit_bug;
      }).catch(() => { btn.disabled = false; btn.textContent = (translations[currentLang]||translations.en).comm_submit_bug; });
    };
  }

  // ===== OS DETECTION =====
  var u = navigator.userAgent;
  var os = 'unknown';
  if (u.indexOf('Win') > -1) os = 'windows';
  else if (u.indexOf('Linux') > -1 && u.indexOf('Android') === -1) os = 'linux';
  else if (u.indexOf('Android') > -1) os = 'android';
  else if (u.indexOf('Mac') > -1) os = 'linux';
  document.querySelectorAll('.download-card').forEach(c => { if (c.dataset.os === os) c.classList.add('featured'); });

  // ===== INIT =====
  // Load translations
  var script = document.createElement('script');
  script.src = 'lang.js?' + Date.now();
  script.onload = function() {
    translations = window.__translations || {};
    if (translations[currentLang]) applyLang(currentLang);
    // Set active lang button
    document.querySelectorAll('.lang-menu button').forEach(b => {
      b.classList.toggle('active', b.dataset.lang === currentLang);
    });
    initReveal();
    loadReviews();
    loadBugs();
  };
  document.head.appendChild(script);

  // Theme icon init
  var themeIcon = document.getElementById('theme-icon');
  if(themeIcon) themeIcon.textContent = savedTheme === 'dark' ? '🌙' : '☀️';
})();

(function(){
  'use strict';

  // ===== Download Counts =====
  function loadCounts() {
    fetch('download.php?action=count&t=' + Date.now())
      .then(r => r.json())
      .then(d => {
        document.getElementById('dl-windows').textContent = d.windows || 0;
        document.getElementById('dl-linux').textContent = d.linux || 0;
        document.getElementById('dl-android').textContent = d.android || 0;
        const total = (d.windows||0) + (d.linux||0) + (d.android||0);
        const el = document.getElementById('total-downloads');
        if (el) el.textContent = total;
      })
      .catch(() => {});
  }
  loadCounts();
  setInterval(loadCounts, 30000);

  // ===== Tabs =====
  document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', function() {
      document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
      this.classList.add('active');
      const target = document.getElementById('tab-' + this.dataset.tab);
      if (target) target.classList.add('active');
    });
  });

  // ===== Star Rating =====
  let selectedRating = 5;
  const stars = document.querySelectorAll('#star-rating .star');
  function updateStars(n) {
    selectedRating = n;
    stars.forEach(s => {
      s.classList.toggle('active', parseInt(s.dataset.value) <= n);
    });
  }
  stars.forEach(s => {
    s.addEventListener('click', () => updateStars(parseInt(s.dataset.value)));
    s.addEventListener('mouseenter', () => {
      stars.forEach(st => st.classList.toggle('hover', parseInt(st.dataset.value) <= parseInt(s.dataset.value)));
    });
    s.addEventListener('mouseleave', () => {
      stars.forEach(st => st.classList.remove('hover'));
    });
  });
  updateStars(5);

  // ===== Load Reviews =====
  function loadReviews() {
    fetch('api.php?type=reviews&action=list&t=' + Date.now())
      .then(r => r.json())
      .then(d => {
        const el = document.getElementById('reviews-list');
        if (!d.items || d.items.length === 0) {
          el.innerHTML = '<div class="empty">No reviews yet. Be the first to share your experience!</div>';
          return;
        }
        el.innerHTML = d.items.map(r => `
          <div class="item-card">
            <div class="item-header">
              <div class="item-avatar">${r.name.charAt(0).toUpperCase()}</div>
              <div class="item-meta">
                <strong>${r.name}</strong>
                <span class="item-platform">${r.platform || ''}</span>
                <span class="item-date">${r.date}</span>
              </div>
              <div class="item-stars">${'&#9733;'.repeat(r.rating || 5)}${'&#9734;'.repeat(5 - (r.rating || 5))}</div>
            </div>
            <p class="item-message">${r.message}</p>
          </div>
        `).join('');
      })
      .catch(() => {
        document.getElementById('reviews-list').innerHTML = '<div class="empty">Failed to load reviews.</div>';
      });
  }

  // ===== Load Bugs =====
  function loadBugs() {
    fetch('api.php?type=bugs&action=list&t=' + Date.now())
      .then(r => r.json())
      .then(d => {
        const el = document.getElementById('bugs-list');
        if (!d.items || d.items.length === 0) {
          el.innerHTML = '<div class="empty">No bug reports yet. Nice!</div>';
          return;
        }
        el.innerHTML = d.items.map(b => {
          const sevClass = {low:'sev-low',medium:'sev-medium',high:'sev-high',critical:'sev-critical'}[b.severity] || 'sev-medium';
          return `
          <div class="item-card">
            <div class="item-header">
              <div class="item-avatar bug-avatar">${b.name.charAt(0).toUpperCase()}</div>
              <div class="item-meta">
                <strong>${b.name}</strong>
                <span class="item-platform">${b.platform || ''} ${b.version ? 'v' + b.version : ''}</span>
                <span class="item-date">${b.date}</span>
              </div>
              <span class="severity ${sevClass}">${b.severity}</span>
            </div>
            <p class="item-title">${b.title || ''}</p>
            <p class="item-message">${b.message}</p>
            ${b.steps ? '<div class="item-steps"><strong>Steps:</strong><pre>' + b.steps + '</pre></div>' : ''}
          </div>`;
        }).join('');
      })
      .catch(() => {
        document.getElementById('bugs-list').innerHTML = '<div class="empty">Failed to load bug reports.</div>';
      });
  }

  loadReviews();
  loadBugs();

  // ===== Submit Review =====
  document.getElementById('review-form').addEventListener('submit', function(e) {
    e.preventDefault();
    const btn = this.querySelector('button[type=submit]');
    btn.disabled = true; btn.textContent = 'Submitting...';
    fetch('api.php?type=reviews', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        name: document.getElementById('review-name').value,
        message: document.getElementById('review-message').value,
        rating: selectedRating,
        platform: document.getElementById('review-platform').value,
      })
    }).then(r => r.json()).then(d => {
      const msg = document.getElementById('review-msg');
      if (d.success) {
        msg.className = 'form-msg success'; msg.textContent = 'Review submitted! Thank you.';
        this.reset(); updateStars(5);
        loadReviews();
        setTimeout(() => {
          document.querySelector('.tab[data-tab="reviews"]').click();
        }, 1500);
      } else {
        msg.className = 'form-msg error'; msg.textContent = d.error || 'Failed';
      }
      btn.disabled = false; btn.textContent = 'Submit Review';
    }).catch(() => {
      document.getElementById('review-msg').className = 'form-msg error';
      document.getElementById('review-msg').textContent = 'Network error. Try again.';
      btn.disabled = false; btn.textContent = 'Submit Review';
    });
  });

  // ===== Submit Bug =====
  document.getElementById('bug-form').addEventListener('submit', function(e) {
    e.preventDefault();
    const btn = this.querySelector('button[type=submit]');
    btn.disabled = true; btn.textContent = 'Submitting...';
    fetch('api.php?type=bugs', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        name: document.getElementById('bug-name').value,
        message: document.getElementById('bug-message').value,
        title: document.getElementById('bug-title').value,
        platform: document.getElementById('bug-platform').value,
        version: document.getElementById('bug-version').value,
        severity: document.getElementById('bug-severity').value,
        steps: document.getElementById('bug-steps').value,
      })
    }).then(r => r.json()).then(d => {
      const msg = document.getElementById('bug-msg');
      if (d.success) {
        msg.className = 'form-msg success'; msg.textContent = 'Bug report submitted! Thank you.';
        this.reset();
        loadBugs();
        setTimeout(() => {
          document.querySelector('.tab[data-tab="bugs"]').click();
        }, 1500);
      } else {
        msg.className = 'form-msg error'; msg.textContent = d.error || 'Failed';
      }
      btn.disabled = false; btn.textContent = 'Submit Bug Report';
    }).catch(() => {
      document.getElementById('bug-msg').className = 'form-msg error';
      document.getElementById('bug-msg').textContent = 'Network error. Try again.';
      btn.disabled = false; btn.textContent = 'Submit Bug Report';
    });
  });

  // ===== OS Detection =====
  const u = navigator.userAgent;
  let os = 'unknown';
  if (u.indexOf('Win') > -1) os = 'windows';
  else if (u.indexOf('Linux') > -1 && u.indexOf('Android') === -1) os = 'linux';
  else if (u.indexOf('Android') > -1) os = 'android';
  else if (u.indexOf('Mac') > -1) os = 'linux';
  document.querySelectorAll('.download-card').forEach(c => {
    if (c.dataset.os === os) c.classList.add('featured');
  });
})();

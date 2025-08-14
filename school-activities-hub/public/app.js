function $(selector, scope = document) { return scope.querySelector(selector); }
function $all(selector, scope = document) { return Array.from(scope.querySelectorAll(selector)); }

function setActiveNav() {
  const path = location.pathname.split('/').pop();
  $all('nav a').forEach((a) => {
    const href = a.getAttribute('href');
    a.classList.toggle('active', href === path || (path === '' && href === 'index.html'));
  });
}

async function apiRequest(url, options = {}) {
  const res = await fetch(url, { headers: { 'Content-Type': 'application/json' }, ...options });
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(text || 'Request failed');
  }
  const contentType = res.headers.get('content-type') || '';
  if (contentType.includes('application/json')) return res.json();
  return res.text();
}

function serializeForm(form) {
  const data = {};
  new FormData(form).forEach((value, key) => { data[key] = value.toString().trim(); });
  return data;
}

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function showStatus(el, message, isError = false) {
  el.textContent = message;
  el.className = isError ? 'error' : 'success';
}

function attachContactFormHandler() {
  const form = $('#contact-form');
  if (!form) return;
  const status = $('#contact-status');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    status.textContent = '';
    const { name, email, message } = serializeForm(form);
    if (!name || !email || !message) return showStatus(status, 'Please fill in all fields.', true);
    if (!validateEmail(email)) return showStatus(status, 'Please enter a valid email.', true);
    try {
      await apiRequest('/api/contact', { method: 'POST', body: JSON.stringify({ name, email, message }) });
      form.reset();
      showStatus(status, 'Message sent! We will get back to you soon.');
    } catch (err) {
      showStatus(status, 'Could not send message. Please try again later.', true);
    }
  });
}

function attachSignupFormHandler(activitySlug) {
  const form = $('#signup-form');
  if (!form) return;
  const status = $('#signup-status');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    status.textContent = '';
    const { name, email, year, message } = serializeForm(form);
    if (!name || !email || !year) return showStatus(status, 'Please fill in all required fields.', true);
    if (!validateEmail(email)) return showStatus(status, 'Please enter a valid email.', true);
    try {
      await apiRequest('/api/signup', { method: 'POST', body: JSON.stringify({ name, email, year, message, activity: activitySlug }) });
      form.reset();
      showStatus(status, 'Thanks for signing up! We will contact you shortly.');
    } catch (err) {
      showStatus(status, 'Could not submit signup. Please try again later.', true);
    }
  });
}

window.App = { setActiveNav, apiRequest, serializeForm, validateEmail, attachContactFormHandler, attachSignupFormHandler };

document.addEventListener('DOMContentLoaded', setActiveNav);
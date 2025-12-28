import { html } from "@elysiajs/html";
import { Elysia } from "elysia";

const styles = `
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
  }
  .container {
    background: white;
    border-radius: 16px;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    padding: 40px;
    width: 100%;
    max-width: 420px;
  }
  .logo {
    text-align: center;
    margin-bottom: 30px;
  }
  .logo h1 {
    color: #667eea;
    font-size: 28px;
    font-weight: 700;
  }
  .logo p {
    color: #6b7280;
    font-size: 14px;
    margin-top: 8px;
  }
  .form-group {
    margin-bottom: 20px;
  }
  label {
    display: block;
    color: #374151;
    font-size: 14px;
    font-weight: 500;
    margin-bottom: 8px;
  }
  input {
    width: 100%;
    padding: 12px 16px;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    font-size: 16px;
    transition: border-color 0.2s, box-shadow 0.2s;
  }
  input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }
  button {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
  }
  button:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px -10px rgba(102, 126, 234, 0.5);
  }
  button:disabled {
    opacity: 0.7;
    cursor: not-allowed;
    transform: none;
  }
  .link {
    text-align: center;
    margin-top: 24px;
    color: #6b7280;
    font-size: 14px;
  }
  .link a {
    color: #667eea;
    text-decoration: none;
    font-weight: 500;
  }
  .link a:hover {
    text-decoration: underline;
  }
  .alert {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 20px;
    font-size: 14px;
  }
  .alert-error {
    background: #fef2f2;
    color: #dc2626;
    border: 1px solid #fecaca;
  }
  .alert-success {
    background: #f0fdf4;
    color: #16a34a;
    border: 1px solid #bbf7d0;
  }
  .hidden { display: none; }
  .user-info {
    background: #f9fafb;
    border-radius: 12px;
    padding: 24px;
    text-align: center;
  }
  .user-info .avatar {
    width: 80px;
    height: 80px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 16px;
    font-size: 32px;
    color: white;
    font-weight: 600;
  }
  .user-info h2 {
    color: #1f2937;
    font-size: 20px;
    margin-bottom: 4px;
  }
  .user-info p {
    color: #6b7280;
    font-size: 14px;
  }
  .user-info .meta {
    margin-top: 16px;
    padding-top: 16px;
    border-top: 1px solid #e5e7eb;
    font-size: 12px;
    color: #9ca3af;
  }
  .btn-logout {
    margin-top: 20px;
    background: #ef4444;
  }
  .btn-logout:hover {
    box-shadow: 0 10px 20px -10px rgba(239, 68, 68, 0.5);
  }
  .nav-links {
    display: flex;
    gap: 16px;
    justify-content: center;
    margin-top: 16px;
  }
  .nav-links a {
    color: #667eea;
    text-decoration: none;
    font-size: 14px;
  }
  .nav-links a:hover {
    text-decoration: underline;
  }
`;

const loginPage = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - Elixir Microservice</title>
  <style>${styles}</style>
</head>
<body>
  <div class="container">
    <div class="logo">
      <h1>Welcome Back</h1>
      <p>Sign in to your account</p>
    </div>

    <div id="error" class="alert alert-error hidden"></div>

    <form id="loginForm">
      <div class="form-group">
        <label for="email">Email</label>
        <input type="email" id="email" name="email" required placeholder="you@example.com">
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" required placeholder="Enter your password">
      </div>

      <button type="submit" id="submitBtn">Sign In</button>
    </form>

    <p class="link">
      Don't have an account? <a href="/auth/register">Sign up</a>
    </p>

    <div class="nav-links">
      <a href="/">Home</a>
      <a href="/swagger">API Docs</a>
    </div>
  </div>

  <script>
    // Redirect to profile if already logged in
    const existingToken = localStorage.getItem('access_token');
    if (existingToken) {
      fetch('/api/auth/validate', {
        headers: { 'Authorization': 'Bearer ' + existingToken }
      }).then(res => {
        if (res.ok) window.location.href = '/auth/profile';
      });
    }

    const form = document.getElementById('loginForm');
    const errorDiv = document.getElementById('error');
    const submitBtn = document.getElementById('submitBtn');

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      errorDiv.classList.add('hidden');
      submitBtn.disabled = true;
      submitBtn.textContent = 'Signing in...';

      const email = document.getElementById('email').value;
      const password = document.getElementById('password').value;

      try {
        const response = await fetch('/api/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password })
        });

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.error || 'Login failed');
        }

        localStorage.setItem('access_token', data.access_token);
        localStorage.setItem('refresh_token', data.refresh_token);
        localStorage.setItem('user', JSON.stringify(data.user));

        window.location.href = '/auth/profile';
      } catch (err) {
        errorDiv.textContent = err.message;
        errorDiv.classList.remove('hidden');
      } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Sign In';
      }
    });
  </script>
</body>
</html>
`;

const registerPage = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register - Elixir Microservice</title>
  <style>${styles}</style>
</head>
<body>
  <div class="container">
    <div class="logo">
      <h1>Create Account</h1>
      <p>Join us today</p>
    </div>

    <div id="error" class="alert alert-error hidden"></div>
    <div id="success" class="alert alert-success hidden"></div>

    <form id="registerForm">
      <div class="form-group">
        <label for="name">Name</label>
        <input type="text" id="name" name="name" placeholder="Your name">
      </div>

      <div class="form-group">
        <label for="email">Email</label>
        <input type="email" id="email" name="email" required placeholder="you@example.com">
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" required minlength="6" placeholder="Min 6 characters">
      </div>

      <button type="submit" id="submitBtn">Create Account</button>
    </form>

    <p class="link">
      Already have an account? <a href="/auth/login">Sign in</a>
    </p>

    <div class="nav-links">
      <a href="/">Home</a>
      <a href="/swagger">API Docs</a>
    </div>
  </div>

  <script>
    // Redirect to profile if already logged in
    const existingToken = localStorage.getItem('access_token');
    if (existingToken) {
      fetch('/api/auth/validate', {
        headers: { 'Authorization': 'Bearer ' + existingToken }
      }).then(res => {
        if (res.ok) window.location.href = '/auth/profile';
      });
    }

    const form = document.getElementById('registerForm');
    const errorDiv = document.getElementById('error');
    const successDiv = document.getElementById('success');
    const submitBtn = document.getElementById('submitBtn');

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      errorDiv.classList.add('hidden');
      successDiv.classList.add('hidden');
      submitBtn.disabled = true;
      submitBtn.textContent = 'Creating account...';

      const name = document.getElementById('name').value;
      const email = document.getElementById('email').value;
      const password = document.getElementById('password').value;

      try {
        const response = await fetch('/api/auth/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password, name })
        });

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.error || 'Registration failed');
        }

        localStorage.setItem('access_token', data.access_token);
        localStorage.setItem('refresh_token', data.refresh_token);
        localStorage.setItem('user', JSON.stringify(data.user));

        window.location.href = '/auth/profile';
      } catch (err) {
        errorDiv.textContent = err.message;
        errorDiv.classList.remove('hidden');
      } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Create Account';
      }
    });
  </script>
</body>
</html>
`;

const profilePage = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Profile - Elixir Microservice</title>
  <style>${styles}</style>
</head>
<body>
  <div class="container">
    <div class="logo">
      <h1>Your Profile</h1>
      <p>Account information</p>
    </div>

    <div id="loading">Loading...</div>
    <div id="error" class="alert alert-error hidden"></div>

    <div id="profile" class="hidden">
      <div class="user-info">
        <div class="avatar" id="avatar">?</div>
        <h2 id="userName">User</h2>
        <p id="userEmail">email@example.com</p>
        <div class="meta">
          <p>User ID: <span id="userId">-</span></p>
          <p>Member since: <span id="userCreated">-</span></p>
        </div>
      </div>

      <button class="btn-logout" onclick="logout()">Sign Out</button>
    </div>

    <div class="nav-links">
      <a href="/">Home</a>
      <a href="/swagger">API Docs</a>
    </div>
  </div>

  <script>
    const token = localStorage.getItem('access_token');
    const loadingDiv = document.getElementById('loading');
    const errorDiv = document.getElementById('error');
    const profileDiv = document.getElementById('profile');

    async function loadProfile() {
      if (!token) {
        window.location.href = '/auth/login';
        return;
      }

      try {
        const response = await fetch('/api/auth/validate', {
          headers: { 'Authorization': 'Bearer ' + token }
        });

        if (!response.ok) {
          throw new Error('Session expired');
        }

        const data = await response.json();
        const user = data.user;

        document.getElementById('avatar').textContent = (user.name || user.email)[0].toUpperCase();
        document.getElementById('userName').textContent = user.name || 'User';
        document.getElementById('userEmail').textContent = user.email;
        document.getElementById('userId').textContent = user.id;
        document.getElementById('userCreated').textContent = new Date(user.created_at).toLocaleDateString();

        loadingDiv.classList.add('hidden');
        profileDiv.classList.remove('hidden');
      } catch (err) {
        localStorage.removeItem('access_token');
        localStorage.removeItem('refresh_token');
        localStorage.removeItem('user');
        window.location.href = '/auth/login';
      }
    }

    function logout() {
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
      localStorage.removeItem('user');
      window.location.href = '/auth/login';
    }

    loadProfile();
  </script>
</body>
</html>
`;

export const authUiRoutes = new Elysia({ prefix: "/auth" })
  .use(html())
  .get("/login", () => loginPage)
  .get("/register", () => registerPage)
  .get("/profile", () => profilePage);

import React, { useState } from 'react';
import axios from 'axios';

// Prefer injected REACT_APP_API_URL (set at build time). If it's provided as an
// empty string the app will use relative paths (e.g. `/api/...`) which is ideal
// for Kubernetes deployments behind an Ingress. Only fall back when the variable
// is strictly undefined.
const API_URL = typeof process.env.REACT_APP_API_URL !== 'undefined'
  ? process.env.REACT_APP_API_URL
  : 'http://localhost:5001';

function Login({ onLoginSuccess, onSwitchToSignup }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await axios.post(`${API_URL}/api/login`, {
        username,
        password
      });

      onLoginSuccess(response.data.token, response.data.user);
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="login-hero">
        <h1 className="login-welcome">Welcome to DevOps World</h1>
        <div className="login-sub">Powering modern delivery — v1.0.0.0 • Author: Akash</div>
      </div>
      <h2>Login</h2>
      {error && <div className="error-message">{error}</div>}
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="username">Username</label>
          <input
            type="text"
            id="username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
            disabled={loading}
          />
        </div>
        <div className="form-group">
          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            disabled={loading}
          />
        </div>
        <button type="submit" className="btn-primary" disabled={loading}>
          {loading ? 'Logging in...' : 'Login'}
        </button>
      </form>
      <div className="switch-link">
        Don't have an account?
        <button onClick={onSwitchToSignup}>Sign up</button>
      </div>
      <div className="auth-footer">v1.0.0.0 — Author: Akash</div>
    </div>
  );
}

export default Login;

import React, { useState, useEffect, useRef } from 'react';
import Login from './components/Login';
import Signup from './components/Signup';
import MainPage from './components/MainPage';
import './App.css';
import SessionTimeoutModal from './components/SessionTimeoutModal';
import GalaxyBackground from './components/GalaxyBackground';

function App() {
  const [currentPage, setCurrentPage] = useState('login');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const inactivityTimeoutRef = useRef(null);
  const INACTIVITY_MS = 5 * 60 * 1000; // 5 minutes
  const WARNING_MS = 30 * 1000; // show modal 30s before logout
  const [showWarning, setShowWarning] = useState(false);
  const [secondsLeft, setSecondsLeft] = useState(Math.ceil(WARNING_MS / 1000));
  const warningIntervalRef = useRef(null);

  // Reset inactivity timer
  const resetInactivityTimer = () => {
    if (inactivityTimeoutRef.current) {
      clearTimeout(inactivityTimeoutRef.current);
    }
    // Clear any existing warning
    setShowWarning(false);
    if (warningIntervalRef.current) {
      clearInterval(warningIntervalRef.current);
      warningIntervalRef.current = null;
    }

    inactivityTimeoutRef.current = setTimeout(() => {
      // Auto logout after inactivity
      handleLogout();
      alert('You have been logged out due to inactivity.');
    }, INACTIVITY_MS);

    // Schedule warning
    const warnAt = INACTIVITY_MS - WARNING_MS;
    setTimeout(() => {
      setShowWarning(true);
      setSecondsLeft(Math.ceil(WARNING_MS / 1000));
      // start countdown
      warningIntervalRef.current = setInterval(() => {
        setSecondsLeft((s) => {
          if (s <= 1 && warningIntervalRef.current) {
            clearInterval(warningIntervalRef.current);
            warningIntervalRef.current = null;
          }
          return s - 1;
        });
      }, 1000);
    }, warnAt);
  };

  const staySignedIn = () => {
    // Reset timers and hide modal
    setShowWarning(false);
    setSecondsLeft(Math.ceil(WARNING_MS / 1000));
    if (warningIntervalRef.current) {
      clearInterval(warningIntervalRef.current);
      warningIntervalRef.current = null;
    }
    resetInactivityTimer();
  };

  // Add activity listeners when authenticated
  useEffect(() => {
    if (!isAuthenticated) return;

    // events that count as activity
    const events = ['mousemove', 'mousedown', 'keydown', 'touchstart', 'click'];

    const handleActivity = () => resetInactivityTimer();

    events.forEach((ev) => window.addEventListener(ev, handleActivity));

    // Start the timer immediately
    resetInactivityTimer();

    return () => {
      events.forEach((ev) => window.removeEventListener(ev, handleActivity));
      if (inactivityTimeoutRef.current) {
        clearTimeout(inactivityTimeoutRef.current);
      }
      if (warningIntervalRef.current) {
        clearInterval(warningIntervalRef.current);
      }
    };
  }, [isAuthenticated]);

  useEffect(() => {
    // Check if user is already logged in
    const token = localStorage.getItem('token');
    const savedUser = localStorage.getItem('user');
    
    if (token && savedUser) {
      setIsAuthenticated(true);
      setUser(JSON.parse(savedUser));
    }
  }, []);

  const handleLoginSuccess = (token, userData) => {
    localStorage.setItem('token', token);
    localStorage.setItem('user', JSON.stringify(userData));
    setIsAuthenticated(true);
    setUser(userData);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setIsAuthenticated(false);
    setUser(null);
    setCurrentPage('login');
  };

  if (isAuthenticated) {
    return (
      <div className="App">
        <GalaxyBackground />
        <MainPage user={user} onLogout={handleLogout} />
        <SessionTimeoutModal
          visible={showWarning}
          secondsLeft={secondsLeft}
          onStaySignedIn={staySignedIn}
        />
      </div>
    );
  }

  return (
    <div className="App">
      <GalaxyBackground />
      {currentPage === 'login' ? (
        <Login 
          onLoginSuccess={handleLoginSuccess}
          onSwitchToSignup={() => setCurrentPage('signup')}
        />
      ) : (
        <Signup 
          onSignupSuccess={handleLoginSuccess}
          onSwitchToLogin={() => setCurrentPage('login')}
        />
      )}
    </div>
  );
}

export default App;

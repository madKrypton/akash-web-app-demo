import React from 'react';

function SessionTimeoutModal({ secondsLeft, onStaySignedIn, visible }) {
  if (!visible) return null;

  return (
    <div className="session-timeout-modal">
      <div className="modal-content">
        <h3>Session Expiring</h3>
        <p>Your session will expire in {secondsLeft} second{secondsLeft !== 1 ? 's' : ''}.</p>
        <div className="modal-actions">
          <button className="btn-primary" onClick={onStaySignedIn}>Stay signed in</button>
        </div>
      </div>
    </div>
  );
}

export default SessionTimeoutModal;

import React, { useEffect, useState } from 'react';
import GalaxyBackground from './GalaxyBackground';

function LazyVideoCard({ videoId, title, description }) {
  const [playing, setPlaying] = useState(false);

  const thumbnail = `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`;

  return (
    <div className="video-card">
      <div className="video-embed">
        {!playing ? (
          <button
            className="video-thumb-btn"
            aria-label={`Play ${title}`}
            onClick={() => setPlaying(true)}
          >
            <img src={thumbnail} alt={`Thumbnail for ${title}`} className="video-thumb" />
            <div className="play-overlay" aria-hidden>
              <div className="play-icon">▶</div>
            </div>
          </button>
        ) : (
          <iframe
            title={title}
            src={`https://www.youtube.com/embed/${videoId}?rel=0`}
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        )}
      </div>
      <div className="video-meta">
        <h4>{title}</h4>
        {description && <p className="video-desc">{description}</p>}
      </div>
    </div>
  );
}

function MainPage({ user, onLogout }) {
  useEffect(() => {
    // When the browser back button is pressed (popstate), treat it as logout
    const handlePopState = () => {
      // Clear auth and notify parent
      try {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
      } catch (e) {
        // ignore
      }
      onLogout();
    };

    window.addEventListener('popstate', handlePopState);

    // Also clear on unmount for safety
    return () => {
      window.removeEventListener('popstate', handlePopState);
      try {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
      } catch (e) {
        // ignore
      }
    };
  }, [onLogout]);
  return (
    <div className="main-page">
      <GalaxyBackground starCount={160} shapeCount={10} />
      <header className="header">
        <h1>DevOps Portal</h1>
        <div className="user-info">
          <span>Welcome, {user.username}!</span>
          <button className="btn-logout" onClick={onLogout}>
            Logout
          </button>
        </div>
      </header>

      <div className="content">
        <div className="welcome-section">
          <h2>Welcome to the DevOps Information Portal</h2>
          <p>Learn about DevOps practices, tools, and methodologies</p>
        </div>

        <div className="devops-info">
          <h3>What is DevOps?</h3>
          
          <div className="devops-section">
            <h4>Overview</h4>
            <p>
              DevOps is a set of practices that combines software development (Dev) and IT operations (Ops). 
              It aims to shorten the systems development life cycle and provide continuous delivery with high software quality.
            </p>
          </div>

          <div className="devops-section">
            <h4>Core Principles</h4>
            <ul>
              <li><strong>Collaboration:</strong> Breaking down silos between development and operations teams</li>
              <li><strong>Automation:</strong> Automating repetitive tasks to increase efficiency and reduce errors</li>
              <li><strong>Continuous Integration:</strong> Regularly merging code changes into a central repository</li>
              <li><strong>Continuous Delivery:</strong> Automating the release process to deploy code changes quickly</li>
              <li><strong>Monitoring & Feedback:</strong> Continuously monitoring applications and infrastructure</li>
            </ul>
          </div>

          <div className="devops-section">
            <h4>Popular DevOps Tools</h4>
            <ul>
              <li><strong>Version Control:</strong> Git, GitHub, GitLab, Bitbucket</li>
              <li><strong>CI/CD:</strong> Jenkins, GitLab CI, GitHub Actions, CircleCI, Travis CI</li>
              <li><strong>Containerization:</strong> Docker, Kubernetes, Docker Compose</li>
              <li><strong>Configuration Management:</strong> Ansible, Puppet, Chef, Terraform</li>
              <li><strong>Monitoring:</strong> Prometheus, Grafana, ELK Stack, Datadog</li>
              <li><strong>Cloud Platforms:</strong> AWS, Azure, Google Cloud Platform</li>
            </ul>
          </div>

          <div className="devops-section">
            <h4>Benefits of DevOps</h4>
            <ul>
              <li>Faster time to market</li>
              <li>Improved collaboration and communication</li>
              <li>Higher quality and more reliable releases</li>
              <li>Reduced deployment failures and faster recovery</li>
              <li>Better resource utilization</li>
              <li>Increased automation and efficiency</li>
            </ul>
          </div>

          <div className="devops-section">
            <h4>DevOps Lifecycle</h4>
            <p>
              The DevOps lifecycle consists of several phases that form a continuous loop:
            </p>
            <ul>
              <li><strong>Plan:</strong> Define requirements and plan the development work</li>
              <li><strong>Code:</strong> Write and review code</li>
              <li><strong>Build:</strong> Compile and build the application</li>
              <li><strong>Test:</strong> Run automated tests to ensure quality</li>
              <li><strong>Release:</strong> Prepare the application for deployment</li>
              <li><strong>Deploy:</strong> Deploy to production environment</li>
              <li><strong>Operate:</strong> Manage and maintain the application</li>
              <li><strong>Monitor:</strong> Track performance and gather feedback</li>
            </ul>
          </div>

          {/* Video card: About DevOps video */}
          <div className="devops-section">
            <LazyVideoCard
              videoId="Xrgk023l4lI"
              title="About DevOps — DevOps Introduction"
              description="Short intro to DevOps practices and why they matter. (Click to play)"
            />
          </div>
        </div>
      </div>
    </div>
  );
}

export default MainPage;

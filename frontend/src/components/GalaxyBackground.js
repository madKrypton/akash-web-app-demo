import React, { useEffect, useRef } from 'react';

function randomBetween(min, max) {
  return Math.random() * (max - min) + min;
}

function GalaxyBackground({ starCount = 120, shapeCount = 8 }) {
  const containerRef = useRef(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    // create stars
    for (let i = 0; i < starCount; i++) {
      const el = document.createElement('div');
      const sizeRoll = Math.random();
      const cls = sizeRoll > 0.95 ? 'large' : sizeRoll > 0.7 ? 'medium' : 'small';
      el.className = `star ${cls}`;
      el.style.left = `${randomBetween(0, 100)}%`;
      el.style.top = `${randomBetween(0, 100)}%`;
      el.style.opacity = String(randomBetween(0.4, 1));
      el.style.animationDelay = `${randomBetween(0, 5)}s`;
      container.appendChild(el);
    }

    // create shapes
    for (let i = 0; i < shapeCount; i++) {
      const el = document.createElement('div');
      const variant = `s${(i % 3) + 1}`;
      el.className = `shape ${variant}`;
      el.style.left = `${randomBetween(0, 100)}%`;
      el.style.top = `${randomBetween(0, 100)}%`;
      el.style.opacity = String(randomBetween(0.25, 0.9));
      el.style.transform = `translateY(0) rotate(${randomBetween(-40,40)}deg)`;
      el.style.animationDelay = `${randomBetween(0, 6)}s`;
      container.appendChild(el);
    }

    // parallax effect
    const handleMove = (e) => {
      const rect = container.getBoundingClientRect();
      const cx = rect.width / 2;
      const cy = rect.height / 2;
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;
      const dx = (mx - cx) / cx; // -1 .. 1
      const dy = (my - cy) / cy;

      // move stars slightly
      const stars = container.querySelectorAll('.star');
      stars.forEach((s, idx) => {
        const depth = (idx % 5) / 5 + 0.2; // 0.2 .. 1.2
        s.style.transform = `translate3d(${dx * depth * 10}px, ${dy * depth * 6}px, 0) scale(1)`;
      });

      const shapes = container.querySelectorAll('.shape');
      shapes.forEach((s, idx) => {
        const depth = (idx % 4) / 4 + 0.4;
        s.style.transform = `translate3d(${dx * depth * 18}px, ${dy * depth * 12}px, 0) rotate(${depth * 30}deg)`;
      });
    };

    window.addEventListener('mousemove', handleMove);

    return () => {
      window.removeEventListener('mousemove', handleMove);
      // cleanup
      while (container.firstChild) container.removeChild(container.firstChild);
    };
  }, [starCount, shapeCount]);

  return <div className="galaxy" ref={containerRef} aria-hidden="true" />;
}

export default GalaxyBackground;

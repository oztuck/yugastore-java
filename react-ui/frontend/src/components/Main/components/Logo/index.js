import React, { PureComponent } from 'react';
import './index.css';

// Original gargoyle/vampire-inspired logo mark for the "modern gothic"
// storefront redesign (specs/storefront-gothic-redesign). Hand-drawn
// silhouette wings + wordmark, no third-party artwork.
class Logo extends PureComponent {
  render() {
    const isLight = this.props.mode === 'light';
    const inkColor = isLight ? '#f0ebf3' : '#1a1420';
    const accentColor = '#A10032';

    return (
      <div className="logo">
        <svg width="256px" height="40px" viewBox="0 0 256 40" version="1.1" xmlns="http://www.w3.org/2000/svg">
          <g id="gothic-logo-mark" stroke="none" fill="none" fillRule="evenodd">
            {/* Gargoyle/bat-wing silhouette mark */}
            <path
              id="wing-mark"
              d="M20 6 C15 10, 8 10, 2 6 C4 14, 10 18, 16 18 C12 22, 6 23, 1 21 C6 28, 14 30, 20 26 C26 30, 34 28, 39 21 C34 23, 28 22, 24 18 C30 18, 36 14, 38 6 C32 10, 25 10, 20 6 Z"
              fill={accentColor}
            />
            {/* Wordmark */}
            <text
              id="wordmark"
              x="48"
              y="27"
              fontFamily="'Inter Tight','Avenir Next Condensed','Segoe UI','Arial Narrow',sans-serif"
              fontSize="22"
              fontWeight="700"
              letterSpacing="1"
              fill={inkColor}
            >
              YUGASTORE
            </text>
          </g>
        </svg>
      </div>
    )
  }
}

export default Logo;

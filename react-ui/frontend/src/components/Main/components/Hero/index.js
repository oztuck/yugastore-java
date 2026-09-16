//Dependencies
import React from 'react';
//Internals
import './index.css';
import backgroundImage from './gothic-background.svg';
import placeholderImage from '../../../common/gothic-placeholder.svg';

const Hero = () => (
  <div className="hero">
    <img
      src={backgroundImage}
      alt="gothic background"
      onError={(e) => { e.target.onerror = null; e.target.src = placeholderImage; }}
    />
  </div>
)

export default Hero;

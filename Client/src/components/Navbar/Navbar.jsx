import './Navbar.css'
import useTheme from '../../hooks/useTheme';

import dark from '../../public/dark.svg'
import light from '../../public/light.svg'

const Navbar = () => {
  const { theme, toggleTheme } = useTheme();
  
  return (
    <nav>
      <h1>MUSIC PORTFOLIO</h1>
      
      <div className="nav-right">
        <a href="https://open.spotify.com/playlist/07XtoHY15Bf0sEy98patB0" target="_blank" rel="noopener noreferrer">Spotify</a>
        <span className="separator">|</span>
        <a href="https://github.com/Ariubilig/SpotifyAPI" target="_blank" rel="noopener noreferrer">Github</a>
        
        <button onClick={toggleTheme} className="theme-toggle-btn">
          <img src={theme === 'dark' ? dark : light} alt="Toggle Theme" className="theme-icon" />
        </button>
      </div>
    </nav>
  )
}

export default Navbar
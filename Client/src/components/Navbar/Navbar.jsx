import './Navbar.css'
import useTheme from '../../hooks/useTheme';

import dark from '../../public/dark.svg'
import light from '../../public/light.svg'


const Navbar = () => {

  const { theme, toggleTheme } = useTheme();
  

  return (
    <>


    <h1>MUSIC PORTFOLIO</h1>

    <button onClick={toggleTheme} className="theme-toggle-btn">
      <img src={theme === 'dark' ? dark : light} alt="Toggle Theme" className="theme-icon" />
    </button>


    </>
  )
}

export default Navbar
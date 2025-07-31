import './App.css'

import Navbar from './components/Navbar/Navbar'


function App() {

  const playlistId = '6RskDizP1J7GhZUwniULrF';

  return (
    <>

    <Navbar/>

    <div className='iframe'>
      <iframe
        title="Spotify Embed: Recommendation Playlist "
        src={`https://open.spotify.com/embed/playlist/6RskDizP1J7GhZUwniULrF?utm_source=generator&theme=0`}
        width="70%"
        height="100%"
        style={{ minHeight: '475px' }}
        frameBorder="0"
        allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture"
        loading="lazy"
        />
      </div>
    </>
  )
}

export default App

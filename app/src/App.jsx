import './App.css'
import { useState } from 'react'
import {
  Owners,
  Rubie,
  Experience,
  Character,
  Weapon
} from './components'


const EComponent = {
  Owners: 'Owners',
  Rubie: 'Rubie',
  Experience: 'Experience',
  Character: 'Character',
  Weapon: 'Weapon'
}

const ComponentMap = {
  [EComponent.Owners]: Owners,
  [EComponent.Rubie]: Rubie,
  [EComponent.Experience]: Experience,
  [EComponent.Character]: Character,
  [EComponent.Weapon]: Weapon
}

function App() {

  const [tab, setTab] = useState(EComponent.Rubie)

  const Component = ComponentMap[tab]

  return (
    <>
      <header className="flex justify-between bg-blue-100 w-full px-20 py-2">
        <h1 className="text-3xl">Rubie World</h1>
        <nav className="flex">
          {Object.values(EComponent).map((component) => (
            <button
              key={component}
              className={`px-4 py-2 ${tab === component ? 'underline' : ''}`}
              onClick={() => setTab(component)}
            >
              {component}
            </button>
          ))}
        </nav>
        <button className="bg-blue-400 rounded-xl py-2 px-4 text-white">Connect</button>
      </header>
      <main>
        <Component />
      </main>
      <footer className="p-2">
        <p>Copyright @ 2023 ORT</p>
      </footer>
    </>
  )
}

export default App

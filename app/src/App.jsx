import './App.css'
import { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import {
  Owners,
  Rubie,
  Experience,
  Character,
  Weapon
} from './pages'
import { useContext } from './context'
import { CONTRACTS, EContract } from './constants'
import { getContractsData } from './utils'
import { Button } from './components'


const ComponentMap = {
  [EContract.Owners]: Owners,
  [EContract.Rubie]: Rubie,
  [EContract.Experience]: Experience,
  [EContract.Character]: Character,
  [EContract.Weapon]: Weapon
}



function App() {

  const { setError, setContracts, setData, data, wallet, setWallet } = useContext()

  const [tab, setTab] = useState(EContract.Rubie)


  const Component = ComponentMap[tab]

  useEffect(() => {
    handleOnConnect()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])


  const handleOnConnect = async () => {
    try {
      if (!window.ethereum) throw new Error('Configure Metamask first')

      if (wallet) throw new Error('You are already connected')


      const provider = new ethers.providers.Web3Provider(window.ethereum)

      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" })


      const _wallet = accounts[0]
      setWallet(_wallet)

      const signer = provider.getSigner(_wallet)


      const contracts = {
        [EContract.Owners]: new ethers.Contract(CONTRACTS.Owners.Address, CONTRACTS.Owners.Abi, signer),
        [EContract.Rubie]: new ethers.Contract(CONTRACTS.Rubie.Address, CONTRACTS.Rubie.Abi, signer),
        [EContract.Experience]: new ethers.Contract(CONTRACTS.Experience.Address, CONTRACTS.Experience.Abi, signer),
        [EContract.Character]: new ethers.Contract(CONTRACTS.Character.Address, CONTRACTS.Character.Abi, signer),
        [EContract.Weapon]: new ethers.Contract(CONTRACTS.Weapon.Address, CONTRACTS.Weapon.Abi, signer)
      }

      setContracts(contracts)

      const _ethers = ethers.utils.formatEther(await provider.getBalance(_wallet));

      const data = await getContractsData(contracts, _wallet)


      setData({
        ethers: _ethers,
        ...data
      })

    } catch (error) {
      setError(error.message)
    }
  }


  return (
    <>
      <header className="flex justify-between bg-blue-100 w-full px-16 py-3">
        <h1 className="text-3xl">Rubie World</h1>
        <nav className="flex">
          {Object.values(EContract).map((component) => (
            <button
              key={component}
              className={`px-4 py-2 ${tab === component ? 'underline' : ''}`}
              onClick={() => setTab(component)}
            >
              {component}
            </button>
          ))}
        </nav>
        <Button onClick={handleOnConnect} isDisabled={wallet}>{wallet ? 'Connected!' : 'Connect'}</Button>
      </header>
      <main className="flex flex-col gap-20">
        <div className='flex flex-col gap-1'>
          {wallet && <div>Wallet {wallet}</div>}
          {data?.ethers && <div>Ethers {data.ethers}</div>}
        </div>
        <Component />
      </main>
      <footer className="p-2">
        <p>Copyright @ 2023 ORT</p>
      </footer>
    </>
  )
}

export default App

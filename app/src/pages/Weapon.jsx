import { labelMap } from "./constants";
import { Button } from "../components";
import { useContext } from "../context";
import { EContract } from "../constants";
import { useRef, useState } from "react";


export const Weapon = () => {
  const { data, contracts, setError } = useContext();

  const nameRef = useRef("");
  const [metadata, setMetadata] = useState();

  if (!data) return null;

  const { [EContract.Weapon]: args } = data

  const obj = {
    name: args.name,
    symbol: args.symbol,
    mintPrice: args.mintPrice,
    totalSupply: args.totalSupply,
    tokenURI: args.tokenURI,
    balance: args.balance,
  }


  const handleSubmit = async (evt) => {
    try {
      evt.preventDefault();
      const name = nameRef.current.value;


      if (!name) {
        setError("Name is required");
        return
      }

      await contracts.Weapon.safeMint(name)
    } catch (err) {
      setError(err.message)
    }
  }


  const addLastWeaponToLastCharacter = async () => {
    try {
      const lastCharacterId = await contracts.Character.totalSupply();
      const lastWeaponId = await contracts.Weapon.totalSupply();
      await contracts.Weapon.addWeaponToCharacter(lastWeaponId, lastCharacterId);
      await contracts.Rubie.approve(contracts.Weapon.address, 0)
    } catch (err) {
      setError(err.message)
    }
  }


  const getMetadataOfLastWeapon = async () => {
    try {
      const lastWeaponId = await contracts.Weapon.totalSupply();
      const metadata = await contracts.Weapon.metadataOf(lastWeaponId);
      setMetadata(metadata);
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <section className="flex gap-5 items-center">
      <div>
        {Object.entries(obj).map(([key, value]) => (
          <p key={key}>{labelMap[key]}: {value}</p>
        ))}
        <div className="h-3"></div>
        <Button onClick={getMetadataOfLastWeapon}>Metadata of Last Weapon</Button>
        {metadata && <>
          <p>Name: {metadata.name}</p>
          <p>Character ID: {metadata.characterID.toString()}</p>
          <p>Attack points: {metadata.attackPoints.toString()}</p>
          <p>Armor points: {metadata.armorPoints.toString()}</p>
          <p>Required experience: {metadata.requiredExperience.toString()}</p>
          <p>On sale: {metadata.onSale ? 'Yes' : 'No'}</p>
        </>}
      </div>
      <div>
        <form className="flex flex-col gap-2" onSubmit={handleSubmit}>
          <input className="w-50 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" type="text" placeholder="Name" ref={nameRef} />
          <Button type="submit">Safe Mint Weapon</Button>
        </form>
        <div className="h-10"></div>
        <Button type="button" onClick={addLastWeaponToLastCharacter}>Add Last Weapon to Last Character</Button>
      </div>
    </section>
  );
};

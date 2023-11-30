import { labelMap } from "./constants";
import { useContext } from "../context";
import { Button } from "../components";
import { EContract } from "../constants";
import { useRef, useState } from "react";

export const Character = () => {
  const { data, contracts, setError } = useContext();

  const nameRef = useRef("");
  const [metadata, setMetadata] = useState();

  if (!data || !contracts) return null;

  const { [EContract.Character]: args } = data

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

      await contracts.Character.safeMint(name, { value: 1 })
    } catch (err) {
      setError(err.message)
    }
  }

  const getMetadataOfLastCharacter = async () => {
    try {
      const lastCharacterId = await contracts.Character.totalSupply();
      const metadata = await contracts.Character.metadataOf(lastCharacterId);
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
        <Button onClick={getMetadataOfLastCharacter}>Metadata of Last Character</Button>
        {metadata && <>
          <p>Name: {metadata.name}</p>
          <p>Attack points: {metadata.attackPoints.toString()}</p>
          <p>Armor points: {metadata.armorPoints.toString()}</p>
          <p>Required experience: {metadata.requiredExperience.toString()}</p>
          <p>Equiped weapons: {metadata.weapon.length > 0 ? metadata.weapon.map(w => w.toString()).join(', ') : '-'}</p>
          <p>On sale: {metadata.onSale ? 'Yes' : 'No'}</p>
        </>}
      </div>
      <form className="flex flex-col gap-2" onSubmit={handleSubmit}>
        <input className="w-50 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" type="text" placeholder="Name" ref={nameRef} />
        <Button type="submit">Safe Mint Character</Button>
      </form>
    </section>
  );
};

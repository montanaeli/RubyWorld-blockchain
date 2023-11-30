import { labelMap } from "./constants";
import { useContext } from "../context";
import { EContract } from "../constants";
import { Button } from "../components";
import { useRef } from "react";

export const Rubie = () => {

  const { data, contracts, setError, wallet } = useContext();

  const rubiesRef = useRef(0);

  if (!data) return null;

  const { [EContract.Rubie]: args } = data


  const obj = {
    name: args.name,
    symbol: args.symbol,
    price: args.price,
    decimals: args.decimals,
    totalSupply: args.totalSupply,
    balance: data.Rubie.balance,
  }

  const handleSubmit = async (evt) => {
    try {
      evt.preventDefault();
      const name = rubiesRef.current.value;


      if (!name) {
        setError("Amount is required");
        return
      }

      await contracts.Rubie.mint(parseInt(name), wallet)
    } catch (err) {
      setError(err.message)
    }
  }

  const resetAllowance = async () => {
    try {
      await contracts.Rubie.approve(contracts.Weapon.address, 0)
    } catch (err) {
      setError(err.message)
    }
  }

  const approve = async () => {
    try {
      await contracts.Rubie.approve(contracts.Weapon.address, parseInt(rubiesRef.current.value))
    }
    catch (err) {
      setError(err.message)
    }
  }


  return (
    <section className="flex gap-5 items-center">
      <div>
        {Object.entries(obj).map(([key, value]) => (
          <p key={key}>{labelMap[key]}: {value}</p>
        ))}
      </div>
      <div>
        <form className="flex flex-col gap-2" onSubmit={handleSubmit}>
          <input type="number" className="w-50 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Amount" ref={rubiesRef} />
          <Button type="submit">Mint Rubies</Button>
          <Button type="button" onClick={approve}>Aprove Weapon to use them</Button>
        </form>
        <div className="h-10"></div>
        <Button onClick={resetAllowance}>Reset Allowance on Weapon</Button>
      </div>
    </section>
  );
};

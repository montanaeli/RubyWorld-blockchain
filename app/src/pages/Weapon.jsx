import { labelMap } from "./constants";
import { useContext } from "../context";
import { EContract } from "../constants";


export const Weapon = () => {
  const { data } = useContext();

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
  return (
    <section>
      {Object.entries(obj).map(([key, value]) => (
        <p key={key}>{labelMap[key]}: {value}</p>
      ))}
    </section>
  );
};
import { labelMap } from "./constants";
import { useContext } from "../context";
import { EContract } from "../constants";

export const Rubie = () => {

  const { data } = useContext();

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

  return (
    <section>
      {Object.entries(obj).map(([key, value]) => (
        <p key={key}>{labelMap[key]}: {value}</p>
      ))}
    </section>
  );
};
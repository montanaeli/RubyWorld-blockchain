import { labelMap } from "./constants";
import { EContract } from "../constants";
import { useContext } from "../context";

export const Experience = () => {

  const { data } = useContext();

  if (!data) return null;

  const { [EContract.Experience]: args } = data

  const obj = {
    name: args.name,
    symbol: args.symbol,
    price: args.price,
    decimals: args.decimals,
    totalSupply: args.totalSupply,
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

import { labelMap } from "./constants";
import { useContext } from "../context";

export const Owners = () => {
  const { data } = useContext();

  if (!data) return null;

  const { Owners: args } = data;

  const props = {
    ownerIndex: args.ownerIndex,
    tokenSellFeePercentage: args.tokenSellFeePercentage,
    balance: args.balance,
  }
  return (
    <section>
      {Object.entries(props).map(([key, value]) => (
        <p key={key}>{labelMap[key]}: {value}</p>
      ))}
    </section>
  );
};

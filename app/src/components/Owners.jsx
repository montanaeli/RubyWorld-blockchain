import { labelMap } from "./constants";

export const Owners = () => {
  const props = {
    ownerIndex: 3,
    tokenSellFeePercentage: 5,
  }
  return (
    <section>
      {Object.entries(props).map(([key, value]) => (
        <p key={key}>{labelMap[key]}: {value}</p>
      ))}
    </section>
  );
};

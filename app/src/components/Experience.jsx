import { labelMap } from "./constants";

export const Experience = () => {
  const props = {
    name: 'Experience',
    symbol: 'EXP',
    price: 0.3,
    decimals: 12,
    totalSupply: 200,
    ownersContract: '0x1234567890123456789012345678901234567890',
  }

  return (
    <section>
      {Object.entries(props).map(([key, value]) => (
        <p key={key}>{labelMap[key]}: {value}</p>
      ))}
    </section>
  );
};

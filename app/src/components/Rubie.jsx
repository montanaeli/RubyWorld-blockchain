import { labelMap } from "./constants";

export const Rubie = () => {

  const props = {
    name: 'Rubie',
    symbol: 'RUBIE',
    price: 0.1,
    decimals: 18,
    totalSupply: 100,
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

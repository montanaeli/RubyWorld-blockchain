import { labelMap } from "./constants";

export const Character = () => {
  const props = {
    name: 'Character',
    symbol: 'CHAR',
    mintPrice: 0.2,
    totalSupply: 300,
    tokenURI: 'https://gateway.pinata.cloud/ipfs/QmZu8mKJyqKXZ2LQ1jQ2QzZkC6B2qJ1w4YrXc5F7Q9pQXt',
  }
  return (
    <section>
      {Object.entries(props).map(([key, value]) => (
        <p key={key}>{labelMap[key]}: {value}</p>
      ))}
    </section>
  );
};

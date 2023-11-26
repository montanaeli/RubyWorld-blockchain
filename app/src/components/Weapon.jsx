import { labelMap } from "./constants";

export const Weapon = () => {
  const props = {
    name: 'Weapon',
    symbol: 'WEAP',
    mintPrice: 0.3,
    totalSupply: 500,
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

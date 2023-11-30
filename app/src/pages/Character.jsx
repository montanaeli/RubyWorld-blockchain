import { labelMap } from "./constants";
import { useContext } from "../context";
import { Button } from "../components";
import { EContract } from "../constants";

export const Character = () => {
  const { data, contracts } = useContext();

  if (!data || !contracts) return null;

  const { [EContract.Character]: args } = data

  const obj = {
    name: args.name,
    symbol: args.symbol,
    mintPrice: args.mintPrice,
    totalSupply: args.totalSupply,
    tokenURI: args.tokenURI,
    balance: args.balance,
  }

  const handleSafeMint = async () => {
    await contracts.Character.safeMint("My new character !!")
  }

  return (
    <section>
      <Button onClick={handleSafeMint}>Safe Mint</Button>
      <div class="h-5"></div>
      {Object.entries(obj).map(([key, value]) => (
        <p key={key}>{labelMap[key]}: {value}</p>
      ))}
    </section>
  );
};

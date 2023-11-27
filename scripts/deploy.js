const { ethers } = require("hardhat");

// Contract to deploy
const contractPath = "src/contracts/Rubie.sol:Rubie";
let contractInstance;

async function main() {
  console.log(
    "---------------------------------------------------------------------------------------"
  );
  console.log("-- Deploy contracts process start...");
  console.log(
    "---------------------------------------------------------------------------------------"
  );

  // Get Signer
  [signer] = await ethers.getSigners();
  const provider = signer.provider;

  // Constructor parameters
  const _name = "TT2-NFT";
  const _symbol = "TT2";
  const zeroAddress = "0x0000000000000000000000000000000000000000";

  // Deploy contract
  const contractFactory = await ethers.getContractFactory(contractPath, signer);
  contractInstance = await contractFactory.deploy(_name, _symbol, zeroAddress);

  console.log("-- Contract Address:\t", contractInstance.address);
  console.log(
    "---------------------------------------------------------------------------------------"
  );
  console.log("-- Contracts have been successfully deployed");
  console.log(
    "---------------------------------------------------------------------------------------"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

const { ethers } = require("hardhat");
const numberOfDecimals = 18;
// Contract to deploy
const ownersContractPath = "./src/contracts/OwnersContract.sol:OwnersContract";
const weaponContractPath = "./src/contracts/Weapon.sol:Weapon";
const characterContractPath = "./src/contracts/Character.sol:Character";
const rubieContractPath = "./src/contracts/Rubie.sol:Rubie";
const experienceContractPath = "./src/contracts/Experience.sol:Experience";

let ownersContractInstance;
let weaponContractInstance;
let characterContractInstance;
let rubieContractInstance;
let experienceContractInstance;

const characterName = "Character_Token";
const characterSymbol = "CHR";
const characterTokenURI = "https://api.example.com/character/1";
const weaponName = "Weapon_Token";
const weaponSymbol = "WPN";
const weaponTokenURI = "https://api.example.com/weapon/1";
const tokenSellFeePercentage = ethers.utils.parseUnits(
  "0.05",
  numberOfDecimals
);
const rubieName = "Rubie_Token";
const rubieSymbol = "RUB";
const experienceName = "Experience_Token";
const experienceSymbol = "EXP";

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

  // Deploy OwnersContract
  const ownersContractFactory = await ethers.getContractFactory(
    ownersContractPath,
    signer
  );
  ownersContractInstance = await ownersContractFactory.deploy(
    tokenSellFeePercentage
  );
  console.log("-- OwnersContract Address:\t", ownersContractInstance.address);

  // Deploy Character Contract
  const characterContractFactory = await ethers.getContractFactory(
    characterContractPath,
    signer
  );
  characterContractInstance = await characterContractFactory.deploy(
    characterName,
    characterSymbol,
    characterTokenURI,
    ownersContractInstance.address
  );
  console.log(
    "-- CharacterContract Address:\t",
    characterContractInstance.address
  );

  // Deploy Weapon Contract
  const weaponContractFactory = await ethers.getContractFactory(
    weaponContractPath,
    signer
  );
  weaponContractInstance = await weaponContractFactory.deploy(
    weaponName,
    weaponSymbol,
    weaponTokenURI,
    ownersContractInstance.address,
    characterContractInstance.address
  );
  console.log("-- WeaponContract Address:\t", weaponContractInstance.address);
  await ownersContractInstance.addOwner(signer.address);

  // Deploy Rubie Contract
  const rubieContractFactory = await ethers.getContractFactory(
    rubieContractPath,
    signer
  );
  rubieContractInstance = await rubieContractFactory.deploy(
    rubieName,
    rubieSymbol,
    ownersContractInstance.address
  );
  console.log("-- RubieContract Address:\t", rubieContractInstance.address);

  // Deploy Experience Contract
  const experienceContractFactory = await ethers.getContractFactory(
    experienceContractPath,
    signer
  );
  experienceContractInstance = await experienceContractFactory.deploy(
    experienceName,
    experienceSymbol,
    ownersContractInstance.address
  );
  console.log(
    "-- ExperienceContract Address:\t",
    experienceContractInstance.address
  );

  // Add Contracts to OwnersContract
  await ownersContractInstance.addContract(
    "Rubie",
    rubieContractInstance.address
  );

  await ownersContractInstance.addContract(
    "Character",
    characterContractInstance.address
  );

  await ownersContractInstance.addContract(
    "Weapon",
    weaponContractInstance.address
  );

  await ownersContractInstance.addContract(
    "Experience",
    experienceContractInstance.address
  );

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

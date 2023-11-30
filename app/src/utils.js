import { EContract } from "./constants";
import { ethers } from "ethers";

const parseEthers = (value) => {
  return ethers.utils.formatEther(value);
};

const parseInt = (value) => {
  return value.toString();
};

export const getContractsData = async (contracts, wallet) => {
  const {
    [EContract.Experience]: experienceContract,
    [EContract.Rubie]: rubieContract,
    [EContract.Owners]: ownersContract,
    [EContract.Weapon]: weaponContract,
    [EContract.Character]: characterContract,
  } = contracts;

  const [
    experienceName,
    experienceSymbol,
    experienceTotalSupply,
    experienceDecimals,
    experiencePrice,
    experienceBalance,
    rubieName,
    rubieSymbol,
    rubieTotalSupply,
    rubieDecimals,
    rubiePrice,
    rubieBalance,
    characterName,
    characterSymbol,
    characterTotalSupply,
    characterTokenURI,
    characterMintPrice,
    characterBalance,
    weaponName,
    weaponSymbol,
    weaponTotalSupply,
    weaponTokenURI,
    weaponMintPrice,
    weaponBalance,
    ownersOwnerIndex,
    ownersTokenSellFeePercentage,
    ownersBalance,
  ] = await Promise.all([
    experienceContract.name(),
    experienceContract.symbol(),
    experienceContract.totalSupply(),
    experienceContract.decimals(),
    experienceContract.price(),
    experienceContract.balanceOf(wallet),
    rubieContract.name(),
    rubieContract.symbol(),
    rubieContract.totalSupply(),
    rubieContract.decimals(),
    rubieContract.price(),
    rubieContract.balanceOf(wallet),
    characterContract.name(),
    characterContract.symbol(),
    characterContract.totalSupply(),
    characterContract.tokenURI(),
    characterContract.mintPrice(),
    characterContract.balanceOf(wallet),
    weaponContract.name(),
    weaponContract.symbol(),
    weaponContract.totalSupply(),
    weaponContract.tokenURI(),
    weaponContract.mintPrice(),
    weaponContract.balanceOf(wallet),
    ownersContract.ownerIndex(),
    ownersContract.tokenSellFeePercentage(),
    ownersContract.balanceOf(wallet),
  ]);

  return {
    [EContract.Experience]: {
      name: experienceName,
      symbol: experienceSymbol,
      totalSupply: parseEthers(experienceTotalSupply),
      decimals: parseInt(experienceDecimals),
      price: parseEthers(experiencePrice),
      balance: parseEthers(experienceBalance),
    },
    [EContract.Rubie]: {
      name: rubieName,
      symbol: rubieSymbol,
      totalSupply: parseEthers(rubieTotalSupply),
      decimals: parseInt(rubieDecimals),
      price: parseEthers(rubiePrice),
      balance: parseEthers(rubieBalance),
    },
    [EContract.Character]: {
      name: characterName,
      symbol: characterSymbol,
      totalSupply: parseInt(characterTotalSupply),
      tokenURI: characterTokenURI,
      mintPrice: parseEthers(characterMintPrice),
      balance: parseInt(characterBalance),
    },
    [EContract.Weapon]: {
      name: weaponName,
      symbol: weaponSymbol,
      totalSupply: parseInt(weaponTotalSupply),
      tokenURI: weaponTokenURI,
      mintPrice: parseEthers(weaponMintPrice),
      balance: parseInt(weaponBalance),
    },
    [EContract.Owners]: {
      ownerIndex: parseInt(ownersOwnerIndex),
      tokenSellFeePercentage: parseEthers(ownersTokenSellFeePercentage),
      balance: parseEthers(ownersBalance),
    },
  };
};

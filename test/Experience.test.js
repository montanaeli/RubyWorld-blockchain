const { ethers } = require("hardhat");

const chai = require("chai");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);
const { expect } = chai;

const zeroAddress = ethers.constants.AddressZero;
const contractPath = "src/contracts/Experience.sol:Experience";

const name = "Experience";
const symbol = "exp";

let ownerAddress;
let ownersContract;
let experienceContract;
let rubieContract;
let characterContract;

describe("Experience tests", () => {
  before(async () => {
    [signer, account1, account2, account3] = await ethers.getSigners();
    provider = ethers.provider;

    const ownersContractFactory = await ethers.getContractFactory(
      "src/contracts/OwnersContract.sol:OwnersContract",
      signer
    );

    ownersContract = await ownersContractFactory.deploy(10);

    const arr = [signer, account1, account2];

    for (let i = 0; i < arr.length; i++) {
      await ownersContract.addOwner(arr[i].address);
    }

    ownerAddress = signer.address;

    const experienceContractFactory = await ethers.getContractFactory(
      contractPath,
      signer
    );

    experienceContract = await experienceContractFactory.deploy(
      name,
      symbol,
      ownersContract.address
    );

    const rubieContractFactory = await ethers.getContractFactory(
      "src/contracts/Rubie.sol:Rubie",
      signer
    );

    rubieContract = await rubieContractFactory.deploy(
      "Rubie",
      "rub",
      ownersContract.address
    );

    const characterContractFactory = await ethers.getContractFactory(
      "src/contracts/Character.sol:Character",
      signer
    );

    characterContract = await characterContractFactory.deploy(
      "Character",
      "cha",
      "a",
      ownersContract.address
    );

    await ownersContract.addContract("Character", characterContract.address);
    await ownersContract.addContract("Rubie", rubieContract.address);
    await ownersContract.addContract("Experience", experienceContract.address);

    await experienceContract.setPrice(1);
  });

  describe("Method buy", () => {
    it("Should buy experience and upgrade character", async () => {
      await characterContract.safeMint("MyCharacter", { value: 1000 });
      const tokenId = await characterContract.getCharacterTokenId(
        signer.address
      );
      expect(await characterContract.ownerOf(tokenId)).to.equal(signer.address);
      const oldMetadata = await characterContract.metadataOf(tokenId);
      const amount = 100;
      await rubieContract.buy(amount, { value: amount });
      await rubieContract.approve(experienceContract.address, amount);
      await experienceContract.buy(amount);
      expect(await experienceContract.balanceOf(signer.address)).to.equal(
        amount
      );
      const newMetadata = await characterContract.metadataOf(tokenId);
      expect(newMetadata.attackPoints).to.equal(
        oldMetadata.attackPoints.add((amount * 5) / 100)
      );
      expect(newMetadata.armorPoints).to.equal(
        oldMetadata.armorPoints.add((amount * 1) / 100)
      );
      expect(newMetadata.sellPrice).to.equal(
        oldMetadata.sellPrice.mul(11).div(10)
      );
      expect(newMetadata.requiredExperience).to.equal(
        oldMetadata.requiredExperience.add(amount)
      );

      it("Should buy experience and do not upgrade character", async () => {
        const amount = 100;
        await rubieContract.buy(amount, { value: amount });
        await rubieContract.approve(experienceContract.address, amount);
        await experienceContract.buy(amount);
        expect(await experienceContract.balanceOf(signer.address)).to.equal(
          amount
        );
        expect(await characterContract.hasCharacter(signer.address)).to.equal(
          false
        );
      });
    });
    it("Everything else is tested in Rubie.tests.js as both classes extends from ERC20", async () => {});
  });
});

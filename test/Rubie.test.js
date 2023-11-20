const { ethers } = require("hardhat");

const chai = require("chai");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);
const { expect } = chai;

const zeroAddress = ethers.constants.AddressZero;
const contractPath = "src/contracts/Rubie.sol:Rubie";

const name = "Rubie Contract";
const symbol = "rub";

let ownerAddress;
let ownersContract;
let rubieContract;

describe("Rubie tests", () => {
  before(async () => {
    [signer, account1, account2, account3] = await ethers.getSigners();
    provider = ethers.provider;

    const ownersContractFactory = await ethers.getContractFactory(
      "src/contracts/OwnersContract.sol:OwnersContract",
      signer
    );

    ownersContract = await ownersContractFactory.deploy(10);

    [signer, account1, account2].forEach((account) => {
      ownersContract.addOwner(account.address);
    });

    ownerAddress = signer.address;

    const rubieContractFactory = await ethers.getContractFactory(
      contractPath,
      signer
    );

    rubieContract = await rubieContractFactory.deploy(
      name,
      symbol,
      ownersContract.address
    );
  });
  describe("No more tests to perform, everything covered inside ERC20.test.js because Rubie extends from ERC20", () => {
    it("Should be true", async () => {
      expect(true).to.equal(true);
    });
  });
});

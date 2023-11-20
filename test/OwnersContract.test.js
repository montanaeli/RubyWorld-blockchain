const { ethers } = require("hardhat");
const chai = require("chai");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);
const { expect } = chai;

let ownersContract;
let owner1;
let owner2;

describe("OwnersContract tests", () => {
  before(async () => {
    [owner1, owner2] = await ethers.getSigners();

    const OwnersContractFactory = await ethers.getContractFactory(
      "OwnersContract"
    );
    ownersContract = await OwnersContractFactory.deploy(5);

    await ownersContract.addOwner(owner1.address);
    await ownersContract.addOwner(owner2.address);

    it("should add an owner", async () => {
      const isOwner = await ownersContract.owners(owner1.address);
      expect(isOwner).to.be.true;
    });

    it("should add another owner", async () => {
      const isOwner = await ownersContract.owners(owner2.address);
      expect(isOwner).to.be.true;
    });

    it("should return owners list", async () => {
      const owner1FromList = await ownersContract.ownersList(0);
      const owner2FromList = await ownersContract.ownersList(1);
      expect(owner1FromList).to.equal(owner1.address);
      expect(owner2FromList).to.equal(owner2.address);
    });

    it("should return the balance of an owner", async () => {
      const balance = await ownersContract.balanceOf(owner1.address);
      expect(balance).to.equal(0); // Owners just added, so balance should be 0
    });

    it("should have earnings to withdraw", async () => {
      const initialBalance = await ethers.provider.getBalance(signer.address);
      await expect(ownersContract.WithdrawEarnings()).to.be.revertedWith(
        "No earnings to withdraw"
      );
    });

    it("should collect fee from a specific contract and distribute it among owners", async () => {
      await ownersContract.addContract(
        "Character",
        ethers.constants.AddressZero
      );

      await ownersContract.deposit({ value: ethers.utils.parseEther("10") });

      const initialBalances = await Promise.all(
        [owner1, owner2].map(
          async (owner) => await ethers.provider.getBalance(owner.address)
        )
      );

      await ownersContract.collectFeeFromContract("Character");

      const finalBalances = await Promise.all(
        [owner1, owner2].map(
          async (owner) => await ethers.provider.getBalance(owner.address)
        )
      );

      const contractBalance = await ethers.provider.getBalance(
        ownersContract.address
      );
      expect(contractBalance).to.equal(0);

      for (let i = 0; i < initialBalances.length; i++) {
        const expectedIncrease = initialBalances[i].add(
          ethers.utils.parseEther("5")
        );
        expect(finalBalances[i]).to.equal(expectedIncrease);
      }
    });

    it("should withdraw earnings", async () => {
      await ownersContract.deposit({ value: ethers.utils.parseEther("10") });

      const initialBalance = await ethers.provider.getBalance(signer.address);
      await ownersContract.withdrawEarnings();
      const finalBalance = await ethers.provider.getBalance(signer.address);

      expect(finalBalance.gt(initialBalance)).to.be.true;
    });
  });
});

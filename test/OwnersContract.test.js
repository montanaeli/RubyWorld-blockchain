// const { ethers } = require("hardhat");
// const chai = require("chai");
// const { solidity } = require("ethereum-waffle");
// chai.use(solidity);
// const { expect } = chai;

// const ownersContractPath = "./src/contracts/OwnersContract.sol:OwnersContract";

// let ownersContract;
// let owner1;
// let owner2;

// describe("OwnersContract tests", () => {
//   before(async () => {
//     console.log()
//     [owner1, owner2] = await ethers.getSigners();

//     const OwnersContractFactory = await ethers.getContractFactory(
//       "OwnersContract"
//     );
//     ownersContract = await OwnersContractFactory.deploy(5);

//     await ownersContract.addOwner(owner1.address);
//     await ownersContract.addOwner(owner2.address);

//     it("should add an owner", async () => {
//       const isOwner = await ownersContract.owners(owner1.address);
//       expect(isOwner).to.be.true;
//     });

//     it("should add another owner", async () => {
//       const isOwner = await ownersContract.owners(owner2.address);
//       expect(isOwner).to.be.true;
//     });

//     it("should return owners list", async () => {
//       const owner1FromList = await ownersContract.ownersList(0);
//       const owner2FromList = await ownersContract.ownersList(1);
//       expect(owner1FromList).to.equal(owner1.address);
//       expect(owner2FromList).to.equal(owner2.address);
//     });

//     it("should return the balance of an owner", async () => {
//       const balance = await ownersContract.balanceOf(owner1.address);
//       expect(balance).to.equal(0); // Owners just added, so balance should be 0
//     });

//     it("should have earnings to withdraw", async () => {
//       const initialBalance = await ethers.provider.getBalance(signer.address);
//       await expect(ownersContract.WithdrawEarnings()).to.be.revertedWith(
//         "No earnings to withdraw"
//       );
//     });

//     it("should collect fee from a specific contract and distribute it among owners", async () => {
//       await ownersContract.addContract(
//         "Character",
//         ethers.constants.AddressZero
//       );

//       await ownersContract.deposit({ value: ethers.utils.parseEther("10") });

//       const initialBalances = await Promise.all(
//         [owner1, owner2].map(
//           async (owner) => await ethers.provider.getBalance(owner.address)
//         )
//       );

//       await ownersContract.collectFeeFromContract("Character");

//       const finalBalances = await Promise.all(
//         [owner1, owner2].map(
//           async (owner) => await ethers.provider.getBalance(owner.address)
//         )
//       );

//       const contractBalance = await ethers.provider.getBalance(
//         ownersContract.address
//       );
//       expect(contractBalance).to.equal(0);

//       for (let i = 0; i < initialBalances.length; i++) {
//         const expectedIncrease = initialBalances[i].add(
//           ethers.utils.parseEther("5")
//         );
//         expect(finalBalances[i]).to.equal(expectedIncrease);
//       }
//     });

//     it("should withdraw earnings", async () => {
//       await ownersContract.deposit({ value: ethers.utils.parseEther("10") });

//       const initialBalance = await ethers.provider.getBalance(signer.address);
//       await ownersContract.withdrawEarnings();
//       const finalBalance = await ethers.provider.getBalance(signer.address);

//       expect(finalBalance.gt(initialBalance)).to.be.true;
//     });
//   });
// });

const { ethers } = require("hardhat");
const chai = require("chai");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);
const { expect } = chai;

const ownersContractPath = "./src/contracts/OwnersContract.sol:OwnersContract";

let ownersContractInstance;
let weaponContractInstance;
let characterContractInstance;
let signer; // The account deploying the contract
let owner1;   // An additional owner for testing

// Constructor parameters
const weaponName = "Weapon_Token";
const weaponSymbol = "WPN";
const weaponTokenURI = "https://api.example.com/weapon/1";
const characterName = "Character_Token";
const characterSymbol = "CHR";
const characterTokenURI = "https://api.example.com/character/1";

describe("OwnersContract Tests", () => {

  // Deploy the OwnersContract before running the tests
  before(async () => {
    console.log("Starting OwnersContract tests");

    [signer, owner1] = await ethers.getSigners();
    const ownersContractFactory = await ethers.getContractFactory(
      ownersContractPath,
      signer
    );
    const characterContractFactory = await ethers.getContractFactory(
      characterContractPath,
      signer
    );
    const weaponContractFactory = await ethers.getContractFactory(
      weaponContractPath,
      signer
    );

    ownersContractInstance = await ownersContractFactory.deploy(10); // Set initial tokenSellFeePercentage to 10
    
    characterContractInstance = await characterContractFactory.deploy(
      characterName,
      characterSymbol,
      characterTokenURI,
      ownersContractInstance.address
    );

    weaponContractInstance = await weaponContractFactory.deploy(
      weaponName,
      weaponSymbol,
      weaponTokenURI,
      ownersContractInstance.address,
      characterContractInstance.address
    );
  
  });

  describe("Constructor tests", () => {
    it("Should deploy with valid parameters", async () => {
      expect(await ownersContractInstance.tokenSellFeePercentage()).to.equal(10);
      expect(await ownersContractInstance.ownerIndex()).to.equal(0);
    });
  });

  describe("Owners function tests", () => {
    it("Should add a new owner", async () => {
      await ownersContractInstance.addOwner(owner1.address);
      expect(await ownersContractInstance.owners(owner1.address)).to.equal(true);
    });

    it("Should not be an owner initially", async () => {
      expect(await ownersContractInstance.owners(signer.address)).to.equal(false);
    });
  });

  describe("Add Contract tests", () => {
    it("Should add a contract address", async () => {
      const contractName = "TestContract";
      const contractAddress = ethers.utils.getAddress("0x1234567890123456789012345678901234567890");
      await ownersContractInstance.addContract(contractName, contractAddress);
      expect(await ownersContractInstance.addressOf(contractName)).to.equal(contractAddress);
    });
  });

  describe("Collect Fee From Contract tests", () => {
    it("Should collect fees from a contract", async () => {
      const contractName = "TestContract";
      const contractAddress = ethers.utils.getAddress("0x1234567890123456789012345678901234567890");
      await ownersContractInstance.addContract(contractName, contractAddress);

      // Mock collectFee function in the TestContract
      await ownersContractInstance.collectFeeFromContract(contractName);

      // Check that the balanceOf the owners has increased
      const owner1BalanceBefore = await signer.getBalance();
      await ownersContractInstance.WithdrawEarnings();
      const owner1BalanceAfter = await signer.getBalance();

      expect(owner1BalanceAfter).to.be.gt(owner1BalanceBefore);
    });
  });

  describe("Withdraw Earnings tests", () => {
    it("Should withdraw earnings", async () => {
      // Deposit some funds to the contract
      await signer.sendTransaction({
        to: ownersContractInstance.address,
        value: ethers.utils.parseEther("1.0")
      });

      const contractBalanceBefore = await ethers.provider.getBalance(ownersContractInstance.address);
      const ownerBalanceBefore = await signer.getBalance();

      await ownersContractInstance.WithdrawEarnings();

      const contractBalanceAfter = await ethers.provider.getBalance(ownersContractInstance.address);
      const ownerBalanceAfter = await signer.getBalance();

      expect(contractBalanceAfter).to.equal(ethers.BigNumber.from("0"));
      expect(ownerBalanceAfter).to.be.gt(ownerBalanceBefore);
    });

    it("Should revert when trying to withdraw with zero balance", async () => {
      await expect(ownersContractInstance.WithdrawEarnings()).to.be.revertedWith("No earnings to withdraw");
    });
  });
});

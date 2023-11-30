const { ethers } = require("hardhat");
const chai = require("chai");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);
const { expect } = chai;

const erc721ContractPath = "./src/contracts/ERC721.sol:ERC721";
const ownersContractPath = "./src/contracts/OwnersContract.sol:OwnersContract";
const weaponContractPath = "./src/contracts/Weapon.sol:Weapon";
const characterContractPath = "./src/contracts/Character.sol:Character";
const rubieContractPath = "./src/contracts/Rubie.sol:Rubie";
const experienceContractPath = "./src/contracts/Experience.sol:Experience";

let ownersContractInstance;
let characterContractInstance;
let rubieContractInstance;
let experienceContractInstance;
const confirmations_number = 1;
const zeroAddress = ethers.constants.AddressZero;

// Constructor parameters
const characterName = "Character_Token";
const characterSymbol = "CHR";
const characterTokenURI = "https://api.example.com/character/1";
const tokenSellFeePercentage = 10;
const rubieName = "Rubie_Token";
const rubieSymbol = "RUB";
const experienceName = "Experience_Token";
const experienceSymbol = "EXP";

describe("OwnersContract Tests", () => {
  // Deploy the OwnersContract before running the tests
  before(async () => {
    console.log("Starting OwnersContract tests");

    // Get Signer and provider
    [signer, owner1, owner2, owner3] = await ethers.getSigners();
    provider = ethers.provider;

    // Deploy Contracts
    const ownersContractFactory = await ethers.getContractFactory(
      ownersContractPath,
      signer
    );

    ownersContract = await ownersContractFactory.deploy(10);

    const characterContractFactory = await ethers.getContractFactory(
      characterContractPath,
      signer
    );
    const rubieContractFactory = await ethers.getContractFactory(
      rubieContractPath,
      signer
    );
    const experienceContractFactory = await ethers.getContractFactory(
      experienceContractPath,
      signer
    );

    ownersContractInstance = await ownersContractFactory.deploy(
      tokenSellFeePercentage
    );

    await ownersContractInstance.addOwner(signer.address);

    rubieContractInstance = await rubieContractFactory.deploy(
      rubieName,
      rubieSymbol,
      ownersContractInstance.address
    );
    experienceContractInstance = await experienceContractFactory.deploy(
      experienceName,
      experienceSymbol,
      ownersContractInstance.address
    );

    characterContractInstance = await characterContractFactory.deploy(
      characterName,
      characterSymbol,
      characterTokenURI,
      ownersContractInstance.address
    );

    // Add contracts to OwnersContract
    await ownersContractInstance.addContract(
      "Rubie",
      rubieContractInstance.address
    );
    await ownersContractInstance.addContract(
      "Character",
      characterContractInstance.address
    );
    await ownersContractInstance.addContract(
      "Experience",
      experienceContractInstance.address
    );

    await rubieContractInstance.setPrice(1);
  });

  describe("Deployment", () => {
    describe("Constructor tests", () => {
      it("Should deploy with valid parameters", async () => {
        expect(await ownersContractInstance.tokenSellFeePercentage()).to.equal(
          10
        );
      });
    });
  });

  describe("addressOf Function", () => {
    it("Should return the correct contract address", async () => {
      await ownersContractInstance.addContract(
        "Character2",
        characterContractInstance.address
      );
      expect(await ownersContractInstance.addressOf("Character2")).to.equal(
        characterContractInstance.address
      );
    });
  });

  describe("Owners function tests", () => {
    it("Should not be an owner initially", async () => {
      expect(await ownersContractInstance.owners(account1.address)).to.equal(
        false
      );
    });

    it("Should add a new owner", async () => {
      await ownersContractInstance.addOwner(account1.address);
      expect(await ownersContractInstance.owners(account1.address)).to.equal(
        true
      );
    });
  });

  describe("Add Contract tests", () => {
    it("Should add a contract address", async () => {
      const contractName = "TestContract";
      const contractAddress = ethers.utils.getAddress(
        "0x1234567890123456789012345678901234567890"
      );
      await ownersContractInstance.addContract(contractName, contractAddress);
      expect(await ownersContractInstance.addressOf(contractName)).to.equal(
        contractAddress
      );
    });
  });
  it("should collect fee from a specific contract and distribute it among owners", async () => {
    const initialBalances = await Promise.all(
      [owner1, owner2].map(
        async (owner) => await ethers.provider.getBalance(owner.address)
      )
    );

    await characterContractInstance.safeMint("Character1");

    const tokenId = await characterContractInstance.totalSupply();

    await characterContractInstance.setOnSale(tokenId, true);

    await rubieContractInstance.connect(account2).buy(1000, { value: 1000 });

    await rubieContractInstance
      .connect(account2)
      .approve(experienceContractInstance.address, 1000);

    await experienceContractInstance.connect(account2).buy(1000);

    await characterContractInstance.connect(account2).buy(tokenId, "NewName", {
      value: 1000,
    });

    // const finalBalances = await Promise.all(
    //   [owner1, owner2].map(
    //     async (owner) => await ethers.provider.getBalance(owner.address)
    //   )
    // );

    // await ownersContract.collectFeeFromContract("Character");

    // const contractBalance = await ethers.provider.getBalance(
    //   ownersContract.address
    // );
    // expect(contractBalance).to.equal(0);

    // for (let i = 0; i < initialBalances.length; i++) {
    //   const expectedIncrease = initialBalances[i].add(
    //     ethers.utils.parseEther("5")
    //   );
    //   expect(finalBalances[i]).to.equal(expectedIncrease);
    // }
  });

  // it("should withdraw earnings", async () => {
  //   await ownersContract.deposit({ value: ethers.utils.parseEther("10") });

  //   const initialBalance = await ethers.provider.getBalance(signer.address);
  //   await ownersContract.withdrawEarnings();
  //   const finalBalance = await ethers.provider.getBalance(signer.address);

  //   expect(finalBalance.gt(initialBalance)).to.be.true;
  // });
});

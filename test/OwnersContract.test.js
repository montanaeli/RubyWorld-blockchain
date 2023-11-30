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

    await rubieContractInstance.setPrice(ethers.utils.parseEther("0.001"));
    await characterContractInstance.setMintPrice(
      ethers.utils.parseEther("0.05")
    );
  });

  describe("Deployment - Constructor tests", () => {
    it("Should deploy with valid parameters", async () => {
      expect(await ownersContractInstance.tokenSellFeePercentage()).to.equal(
        10
      );
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
      expect(await ownersContractInstance.owners(owner1.address)).to.equal(
        false
      );
    });

    it("Should add a new owner", async () => {
      await ownersContractInstance.addOwner(owner1.address);
      expect(await ownersContractInstance.owners(owner1.address)).to.equal(
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

  describe("Fees tests", () => {
    it("Try to withdraw earnings from a non-owner account", async () => {
      await expect(
        ownersContractInstance.connect(owner2).WithdrawEarnings()
      ).to.be.revertedWith("Not the owner");
    });

    it("Try to withdraw earnings without earnings", async () => {
      await expect(
        ownersContractInstance.WithdrawEarnings()
      ).to.be.revertedWith("No earnings to withdraw");
    });

    it("should collect fee from a specific contract and distribute it among owners", async () => {
      const ownersContract_balance = await ethers.provider.getBalance(
        ownersContractInstance.address
      );

      await characterContractInstance.safeMint("Character1", {
        value: ethers.utils.parseEther("0.05"),
      });
      const tokenId = await characterContractInstance.totalSupply();

      await characterContractInstance.setOnSale(tokenId, true);
      await rubieContractInstance.connect(owner2).buy(1000, { value: 1000 });
      await rubieContractInstance
        .connect(owner2)
        .approve(experienceContractInstance.address, 1000);
      await experienceContractInstance.connect(owner2).buy(1000);
      await characterContractInstance.connect(owner2).buy(tokenId, "NewName", {
        value: ethers.utils.parseEther("0.05"),
      });

      await ownersContractInstance.collectFeeFromContract("Character");

      const ownersContract_balance_after = await ethers.provider.getBalance(
        ownersContractInstance.address
      );

      expect(ownersContract_balance_after.gt(ownersContract_balance)).to.be
        .true;
    });

    it("Should withdraw earnings", async () => {
      const signer_balance_before = await ethers.provider.getBalance(
        signer.address
      );
      const owner1_balance_before = await ethers.provider.getBalance(
        owner1.address
      );

      await ownersContractInstance.WithdrawEarnings();

      const signer_balance_after = await ethers.provider.getBalance(
        signer.address
      );
      const owner1_balance_after = await ethers.provider.getBalance(
        owner1.address
      );

      expect(signer_balance_after.gt(signer_balance_before)).to.be.true;
      expect(owner1_balance_after.gt(owner1_balance_before)).to.be.true;
    });
  });
});

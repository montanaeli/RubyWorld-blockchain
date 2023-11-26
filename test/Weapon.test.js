const { ethers } = require("hardhat");
const chai = require("chai");
const { solidity } = require("ethereum-waffle");
const { ConstructorFragment } = require("ethers/lib/utils");
chai.use(solidity);
const { expect } = chai;
const erc721ContractPath = "./src/contracts/ERC721.sol:ERC721";
const ownersContractPath = "./src/contracts/OwnersContract.sol:OwnersContract";
const weaponContractPath = "./src/contracts/Weapon.sol:Weapon";
const characterContractPath = "./src/contracts/Character.sol:Character";
const rubieContractPath = "./src/contracts/Rubie.sol:Rubie";
const experienceContractPath = "./src/contracts/Experience.sol:Experience";
const DECIMAL_FACTOR = 10 ** 18;

const confirmations_number = 1;
const zeroAddress = "0x0000000000000000000000000000000000000000";
let ownersContractInstance;
let weaponContractInstance;
let characterContractInstance;
let rubieContractInstance;
let experienceContractInstance;

// Constructor parameters
const weaponName = "Weapon_Token";
const weaponSymbol = "WPN";
const weaponTokenURI = "https://api.example.com/weapon/1";
const characterName = "Character_Token";
const characterSymbol = "CHR";
const characterTokenURI = "https://api.example.com/character/1";
const tokenSellFeePercentage = 0; // // 0.015 (1.5%)
const rubieName = "Rubie_Token";
const rubieSymbol = "RUB";
const experienceName = "Experience_Token";
const experienceSymbol = "EXP";

describe("Weapon Tests", () => {
  before(async () => {
    console.log("Starting Weapon tests");

    // Get Signer and provider
    [signer, account1, account2, account3] = await ethers.getSigners();
    provider = ethers.provider;

    // Deploy Contracts
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
    const rubieContractFactory = await ethers.getContractFactory(
      rubieContractPath,
      signer
    );
    const experienceContractFactory = await ethers.getContractFactory(
      experienceContractPath,
      signer
    );

    ownersContractInstance = await ownersContractFactory.deploy(
      tokenSellFeePercentage * DECIMAL_FACTOR
    );

    ownersContractInstance.addOwner(signer.address);

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

    weaponContractInstance = await weaponContractFactory.deploy(
      weaponName,
      weaponSymbol,
      weaponTokenURI,
      ownersContractInstance.address,
      characterContractInstance.address
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
    await ownersContractInstance.addContract(
      "Weapon",
      weaponContractInstance.address
    );

    // Set weapon mintPrice
    await weaponContractInstance.setMintPrice(100);
  });

  describe("Deploy tests", () => {
    it("Try send empty name", async () => {
      const contractFactory = await ethers.getContractFactory(
        weaponContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          "",
          weaponSymbol,
          weaponTokenURI,
          ownersContractInstance.address,
          characterContractInstance.address
        )
      ).to.be.reverted;
    });

    it("Try send empty symbol", async () => {
      const contractFactory = await ethers.getContractFactory(
        weaponContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          weaponName,
          "",
          weaponTokenURI,
          ownersContractInstance.address,
          characterContractInstance.address
        )
      ).to.be.reverted;
    });

    it("Try send symbol with 2 characters long", async () => {
      const contractFactory = await ethers.getContractFactory(
        weaponContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          weaponName,
          "ab",
          weaponTokenURI,
          ownersContractInstance.address,
          characterContractInstance.address
        )
      ).to.be.reverted;
    });

    it("Try send symbol with 4 characters long", async () => {
      const contractFactory = await ethers.getContractFactory(
        weaponContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          weaponName,
          "abcd",
          weaponTokenURI,
          ownersContractInstance.address,
          characterContractInstance.address
        )
      ).to.be.reverted;
    });

    it("Try send zero address on owners contract", async () => {
      const contractFactory = await ethers.getContractFactory(
        weaponContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          weaponName,
          weaponSymbol,
          weaponTokenURI,
          zeroAddress,
          characterContractInstance.address
        )
      ).to.be.reverted;
    });

    it("Try send zero address on character contract", async () => {
      const contractFactory = await ethers.getContractFactory(
        weaponContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          weaponName,
          weaponSymbol,
          weaponTokenURI,
          ownersContractInstance.address,
          zeroAddress
        )
      ).to.be.reverted;
    });
  });

  describe("Initialization test", () => {
    it("Initialization test", async () => {
      expect(await weaponContractInstance.name()).to.equal(weaponName);
      expect(await weaponContractInstance.symbol()).to.equal(weaponSymbol);
      expect(await weaponContractInstance.tokenURI()).to.equal(weaponTokenURI);
      expect(await weaponContractInstance.ownersContract()).to.equal(
        ownersContractInstance.address
      );
      expect(await weaponContractInstance.characterContract()).to.equal(
        characterContractInstance.address
      );
    });
  });

  describe("Safe Mint tests", () => {
    it("Try mint with empty name", async () => {
      await expect(weaponContractInstance.safeMint(signer.address, "")).to.be
        .reverted;
    });

    it("Try mint a Weapon without Rubies", async () => {
      const _name = "Sword of Power";
      await expect(weaponContractInstance.safeMint(_name)).to.be.revertedWith(
        "Insufficient balance"
      );
    });

    it("Try mint a Weapon without Allowance", async () => {
      const _name = "Sword of Power";
      await rubieContractInstance.mint(100, signer.address);
      await expect(weaponContractInstance.safeMint(_name)).to.be.revertedWith(
        "Insufficient allowance"
      );
    });

    it("Should mint a Weapon with correct name", async () => {
      await rubieContractInstance.approve(weaponContractInstance.address, 100);
      const _recipient = signer.address;
      const _name = "Sword of Power";

      // State before the transaction
      const signerEtherBalance_before = await provider.getBalance(
        signer.address
      );
      const totalSupply_before = await weaponContractInstance.totalSupply();
      const recipientBalanceOf_before = await weaponContractInstance.balanceOf(
        _recipient
      );

      console.log("Before calling mint");

      const tx = await weaponContractInstance.safeMint(_name);
      const tx_receipt = await tx.wait(confirmations_number);

      console.log("After calling mint");

      const _gas = tx_receipt.cumulativeGasUsed;
      const _gasPrice = tx_receipt.effectiveGasPrice;
      const _gasPaid = _gas.mul(_gasPrice);

      const signerEtherBalance_after = await provider.getBalance(
        signer.address
      );
      const totalSupply_after = await weaponContractInstance.totalSupply();
      const recipientBalanceOf_after = await weaponContractInstance.balanceOf(
        _recipient
      );
      const ownerOf_after = await weaponContractInstance.ownerOf(
        totalSupply_after
      );

      expect(signerEtherBalance_after).to.be.equals(
        signerEtherBalance_before.sub(_gasPaid)
      );
      expect(totalSupply_after).to.be.equals(totalSupply_before.add(1));
      expect(recipientBalanceOf_after).to.be.equals(
        recipientBalanceOf_before.add(1)
      );
      expect(ownerOf_after).to.be.equals(_recipient);
    });
  });

  describe("Mint Legendary Weapon tests", () => {
    it("Try mint Legendary Weapon with invalid attackPoints", async () => {
      await expect(
        weaponContractInstance.mintLegendaryWeapon(0, 0, 0, 0)
      ).to.be.revertedWith("Invalid _attackPoints");
    });

    it("Try mint Legendary Weapon with invalid armorPoints", async () => {
      await expect(
        weaponContractInstance.mintLegendaryWeapon(155, 0, 0, 0)
      ).to.be.revertedWith("Invalid _armorPoints");
    });

    it("Try mint Legendary Weapon with invalid sellPrice", async () => {
      await expect(
        weaponContractInstance.mintLegendaryWeapon(155, 101, 0, 0)
      ).to.be.revertedWith("Invalid _sellPrice");
    });

    it("Try mint Legendary Weapon with invalid required experience", async () => {
      await expect(
        weaponContractInstance.mintLegendaryWeapon(155, 101, 150, 0)
      ).to.be.revertedWith("Invalid _requiredExperience");
    });

    it("Should mint a Legendary Weapon", async () => {
      const _name = "Lengendary weapon name";
      const _attackPoints = 155;
      const _armorPoints = 101;
      const _sellPrice = 150;
      const _requiredExperience = 100;

      const totalSupply_before = await weaponContractInstance.totalSupply();

      // Perform the legendary weapon mint and then validate if all the data is corrent
      await weaponContractInstance.mintLegendaryWeapon(
        _attackPoints,
        _armorPoints,
        _sellPrice,
        _requiredExperience
      );

      const totalSupply_after = await weaponContractInstance.totalSupply();
      expect(totalSupply_after).to.be.equals(totalSupply_before.add(1));

      const legendaryWeaponMetadata = await weaponContractInstance.metadataOf(
        totalSupply_after
      );
      expect(legendaryWeaponMetadata.name).to.be.equals(_name);
      expect(legendaryWeaponMetadata.attackPoints).to.be.equals(_attackPoints);
      expect(legendaryWeaponMetadata.armorPoints).to.be.equals(_armorPoints);
      expect(legendaryWeaponMetadata.sellPrice).to.be.equals(_sellPrice);
      expect(legendaryWeaponMetadata.requiredExperience).to.be.equals(
        _requiredExperience
      );
      expect(legendaryWeaponMetadata.onSale).to.be.equals(true);
    });
  });

  describe("Get Sell Information tests", () => {
    it("Try get sell information of an invalid token id", async () => {
      await expect(
        weaponContractInstance.getSellInformation(0)
      ).to.be.revertedWith("Invalid tokenId");
    });

    it("Should get sell information of a token", async () => {
      const _tokenId = 1;
      const [
        _characterId,
        _attackPoints,
        _armorPoints,
        _sellPrice,
        _requiredExperience,
        _name,
        _onSale,
      ] = await weaponContractInstance.metadataOf(_tokenId);

      const [onSale, sellPrice, requiredExperience] =
        await weaponContractInstance.getSellInformation(_tokenId);

      expect(onSale).to.be.equals(_onSale);
      expect(sellPrice.toNumber()).to.be.equals(_sellPrice);
      expect(requiredExperience.toNumber()).to.be.equals(_requiredExperience);
    });
  });

  describe("Buy weapon tests", () => {
    it("Try buy a weapon with not enough Rubies", async () => {
      await expect(
        weaponContractInstance.buy(1, "New Name", { value: 50 })
      ).to.be.revertedWith("Not enough Rubies");
    });

    it("Try buy a weapon with an invalid tokenId", async () => {
      await expect(
        weaponContractInstance.buy(0, "New Name", { value: 200 })
      ).to.be.revertedWith("Invalid tokenId");
    });

    it("Try to buy a weapon that is not on sale", async () => {
      weaponContractInstance.setOnSale(1, false);
      await expect(
        weaponContractInstance.buy(1, "New Name", { value: 200 })
      ).to.be.revertedWith("weapon not on sale");

      weaponContractInstance.setOnSale(1, true);
    });

    it("Try to buy a weapon with not enough experience", async () => {
      await expect(
        weaponContractInstance.buy(1, "New Name", { value: 200 })
      ).to.be.revertedWith("Insufficient experience");
    });

    // TODO: Test buy with enough Rubies and experience and the rest of the functionality
  });

  describe("Weapon on sale tests", () => {
    it("Try set on sale an invalid tokenId", async () => {
      await expect(
        weaponContractInstance.setOnSale(0, true)
      ).to.be.revertedWith("Invalid tokenId");
    });
    it("Try set on sale a token that is not owned by the sender", async () => {
      // Try to setOnSale a token that is not owned by the sender
      //Change the signer
      const [signer] = await ethers.getSigners();
      await expect(
        weaponContractInstance.connect(account1).setOnSale(1, true)
      ).to.be.revertedWith("Not authorized");
    });

    it("Weapon should be on sale", async () => {
      const _tokenId = 1;
      const [onSale] = await weaponContractInstance.getSellInformation(
        _tokenId
      );
      expect(onSale).to.be.equals(true);
    });

    it("Change weapon onSale variable", async () => {
      const _tokenId = 1;
      await weaponContractInstance.setOnSale(_tokenId, false);
      const [onSale] = await weaponContractInstance.getSellInformation(
        _tokenId
      );
      expect(onSale).to.be.equals(false);
    });
  });
});

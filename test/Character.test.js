const { ethers } = require("hardhat");
const chai = require("chai");
const { solidity } = require("ethereum-waffle");
const { ConstructorFragment } = require("ethers/lib/utils");
chai.use(solidity);
const { expect } = chai;
const ownersContractPath = "./src/contracts/OwnersContract.sol:OwnersContract";
const weaponContractPath = "./src/contracts/Weapon.sol:Weapon";
const characterContractPath = "./src/contracts/Character.sol:Character";
const rubieContractPath = "./src/contracts/Rubie.sol:Rubie";
const experienceContractPath = "./src/contracts/Experience.sol:Experience";

const confirmations_number = 1;
const zeroAddress = ethers.constants.AddressZero;
let ownersContractInstance;
let weaponContractInstance;
let characterContractInstance;
let rubieContractInstance;
let experienceContractInstance;

// Constructor parameters
const characterName = "Character_Token";
const characterSymbol = "CHR";
const characterTokenURI = "https://api.example.com/character/1";
const weaponName = "Weapon_Token";
const weaponSymbol = "WPN";
const weaponTokenURI = "https://api.example.com/weapon/1";
const tokenSellFeePercentage = 5;
const rubieName = "Rubie_Token";
const rubieSymbol = "RUB";
const experienceName = "Experience_Token";
const experienceSymbol = "EXP";

describe("Character Tests", () => {
  before(async () => {
    console.log("Starting Character tests");

    // Get Signer and provider
    [signer, account1, account2, account3, account4] =
      await ethers.getSigners();
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
    const rubieContractFactory = await ethers.getContractFactory(
      rubieContractPath,
      signer
    );

    const weaponContractFactory = await ethers.getContractFactory(
      weaponContractPath,
      signer
    );

    const experienceContractFactory = await ethers.getContractFactory(
      experienceContractPath,
      signer
    );

    ownersContractInstance = await ownersContractFactory.deploy(
      tokenSellFeePercentage
    );
    await ownersContractInstance.deployed();

    await ownersContractInstance.addOwner(signer.address);

    characterContractInstance = await characterContractFactory.deploy(
      characterName,
      characterSymbol,
      characterTokenURI,
      ownersContractInstance.address
    );
    await characterContractInstance.deployed();

    weaponContractInstance = await weaponContractFactory.deploy(
      weaponName,
      weaponSymbol,
      weaponTokenURI,
      ownersContractInstance.address,
      characterContractInstance.address
    );

    rubieContractInstance = await rubieContractFactory.deploy(
      rubieName,
      rubieSymbol,
      ownersContractInstance.address
    );
    await rubieContractInstance.deployed();

    experienceContractInstance = await experienceContractFactory.deploy(
      experienceName,
      experienceSymbol,
      ownersContractInstance.address
    );
    await experienceContractInstance.deployed();

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
      "Weapon",
      weaponContractInstance.address
    );

    await ownersContractInstance.addContract(
      "Experience",
      experienceContractInstance.address
    );

    // Set Character Mint Price
    await characterContractInstance.setMintingPrice(
      ethers.utils.parseEther("0.005")
    );

    // Set Rubie Mint Price
    await rubieContractInstance.setPrice(ethers.utils.parseEther("0.001"));

    // Set Experience Mint Price
    await experienceContractInstance.setPrice(
      ethers.utils.parseEther("0.0001")
    );

    // Set Weapon Mint Price
    await weaponContractInstance.setMintPrice(50);
  });

  describe("Deploy & initialization tests", () => {
    it("Try send empty name", async () => {
      const contractFactory = await ethers.getContractFactory(
        characterContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          "",
          characterSymbol,
          characterTokenURI,
          ownersContractInstance.address
        )
      ).to.be.revertedWith(
        "_name, _symbol and _tokenURI are mandatory parameters"
      );
    });

    it("Try send empty symbol", async () => {
      const contractFactory = await ethers.getContractFactory(
        characterContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          characterName,
          "",
          characterTokenURI,
          ownersContractInstance.address
        )
      ).to.be.revertedWith(
        "_name, _symbol and _tokenURI are mandatory parameters"
      );
    });

    it("Try send empty tokenURI", async () => {
      const contractFactory = await ethers.getContractFactory(
        characterContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          characterName,
          characterSymbol,
          "",
          ownersContractInstance.address
        )
      ).to.be.revertedWith(
        "_name, _symbol and _tokenURI are mandatory parameters"
      );
    });

    it("Try send symbol with 2 characters long", async () => {
      const contractFactory = await ethers.getContractFactory(
        characterContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          characterName,
          "aa",
          characterTokenURI,
          ownersContractInstance.address
        )
      ).to.be.revertedWith("Invalid symbol");
    });

    it("Try send symbol with 4 characters long", async () => {
      const contractFactory = await ethers.getContractFactory(
        characterContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          characterName,
          "abcd",
          characterTokenURI,
          ownersContractInstance.address
        )
      ).to.be.revertedWith("Invalid symbol");
    });

    it("Try send zero address on owners contract", async () => {
      const contractFactory = await ethers.getContractFactory(
        characterContractPath,
        signer
      );
      await expect(
        contractFactory.deploy(
          characterName,
          characterSymbol,
          characterTokenURI,
          zeroAddress
        )
      ).to.be.revertedWith("Invalid address");
    });

    it("Deploy a correct contract and check initial information", async () => {
      const contractFactory = await ethers.getContractFactory(
        characterContractPath,
        signer
      );
      const contractInstance = await contractFactory.deploy(
        characterName,
        characterSymbol,
        characterTokenURI,
        ownersContractInstance.address
      );
      await contractInstance.deployed();
      expect(await contractInstance.name()).to.equal(characterName);
      expect(await contractInstance.symbol()).to.equal(characterSymbol);
      expect(await contractInstance.tokenURI()).to.equal(characterTokenURI);
      expect(await contractInstance.ownersContract()).to.equal(
        ownersContractInstance.address
      );
    });
  });

  describe("Mint test", () => {
    it("Try safeMint without name", async () => {
      await expect(characterContractInstance.safeMint("")).to.be.revertedWith(
        "Invalid name"
      );
    });

    it("Try safeMint without enouth ETH", async () => {
      await expect(
        characterContractInstance.safeMint("Character 1", {
          value: ethers.utils.parseEther("0.004"),
        })
      ).to.be.revertedWith("Not enough ETH");
    });

    it("Mint new character with signer account", async () => {
      const signerAccountRubies_before = await rubieContractInstance.balanceOf(
        signer.address
      );
      const totalSupply_before = await characterContractInstance.totalSupply();
      const signerBalance_before = await characterContractInstance.balanceOf(
        signer.address
      );
      const signerEtherBalance_before = await provider.getBalance(
        signer.address
      );

      const tx = await characterContractInstance.safeMint("Character 1", {
        value: ethers.utils.parseEther("0.005"),
      });
      const tx_receipt = await tx.wait(confirmations_number);

      const _gas = tx_receipt.cumulativeGasUsed;
      const _gasPrice = tx_receipt.effectiveGasPrice;
      const _gasPaid = _gas.mul(_gasPrice);

      const signerEtherBalance_after = await provider.getBalance(
        signer.address
      );
      const signerAccountRubies_after = await rubieContractInstance.balanceOf(
        signer.address
      );
      const totalSupply_after = await characterContractInstance.totalSupply();
      const signerBalance_after = await characterContractInstance.balanceOf(
        signer.address
      );
      const ownerOf_after = await characterContractInstance.ownerOf(
        totalSupply_after
      );

      expect(signerEtherBalance_after).to.be.equals(
        signerEtherBalance_before
          .sub(ethers.utils.parseEther("0.005"))
          .sub(_gasPaid)
      );
      expect(signerAccountRubies_after).to.be.equals(
        signerAccountRubies_before.add(1000)
      );
      expect(totalSupply_after).to.be.equals(totalSupply_before.add(1));
      expect(signerBalance_after).to.be.equals(signerBalance_before.add(1));
      expect(ownerOf_after).to.be.equals(signer.address);
    });

    it("Minted character metadata should be correct", async () => {
      const characterName = "Character 1";
      const baseAttackPoints = 100;
      const baseArmorPoints = 50;
      const baseRequiredExperience = 100;
      const totalSupply = await characterContractInstance.totalSupply();
      const mintedCharacterMetadata =
        await characterContractInstance.metadataOf(totalSupply);

      expect(mintedCharacterMetadata.name).to.be.equals(characterName);
      expect(mintedCharacterMetadata.attackPoints).to.be.equals(
        baseAttackPoints
      );
      expect(mintedCharacterMetadata.armorPoints).to.be.equals(baseArmorPoints);
      expect(mintedCharacterMetadata.requiredExperience).to.be.equals(
        baseRequiredExperience
      );
      expect(mintedCharacterMetadata.onSale).to.be.equals(false);
    });

    it("Try mint a character with another account", async () => {
      const account1AccountRubies_before =
        await rubieContractInstance.balanceOf(account1.address);
      const totalSupply_before = await characterContractInstance.totalSupply();
      const account1Balance_before = await characterContractInstance.balanceOf(
        account1.address
      );
      const account1EtherBalance_before = await provider.getBalance(
        account1.address
      );

      const tx = await characterContractInstance
        .connect(account1)
        .safeMint("Character 2", {
          value: ethers.utils.parseEther("0.005"),
        });
      const tx_receipt = await tx.wait(confirmations_number);

      const _gas = tx_receipt.cumulativeGasUsed;
      const _gasPrice = tx_receipt.effectiveGasPrice;
      const _gasPaid = _gas.mul(_gasPrice);

      const account1EtherBalance_after = await provider.getBalance(
        account1.address
      );
      const account1AccountRubies_after = await rubieContractInstance.balanceOf(
        account1.address
      );
      const totalSupply_after = await characterContractInstance.totalSupply();
      const account1Balance_after = await characterContractInstance.balanceOf(
        account1.address
      );
      const ownerOf_after = await characterContractInstance.ownerOf(
        totalSupply_after
      );

      expect(account1EtherBalance_after).to.be.equals(
        account1EtherBalance_before
          .sub(ethers.utils.parseEther("0.005"))
          .sub(_gasPaid)
      );
      expect(account1AccountRubies_after).to.be.equals(
        account1AccountRubies_before.add(1000)
      );
      expect(totalSupply_after).to.be.equals(totalSupply_before.add(1));
      expect(account1Balance_after).to.be.equals(account1Balance_before.add(1));
      expect(ownerOf_after).to.be.equals(account1.address);
    });

    it("Minted character with different account metadata should be correct", async () => {
      const characterName = "Character 2";
      const baseAttackPoints = 100;
      const baseArmorPoints = 50;
      const baseRequiredExperience = 100;
      const totalSupply = await characterContractInstance.totalSupply();
      const mintedCharacterMetadata =
        await characterContractInstance.metadataOf(totalSupply);

      expect(mintedCharacterMetadata.name).to.be.equals(characterName);
      expect(mintedCharacterMetadata.attackPoints).to.be.equals(
        baseAttackPoints
      );
      expect(mintedCharacterMetadata.armorPoints).to.be.equals(baseArmorPoints);
      expect(mintedCharacterMetadata.requiredExperience).to.be.equals(
        baseRequiredExperience
      );
      expect(mintedCharacterMetadata.onSale).to.be.equals(false);
    });

    it("Try mint a character with another account with less than minting price", async () => {
      await expect(
        characterContractInstance.connect(account2).safeMint("Character 3", {
          value: ethers.utils.parseEther("0.004"),
        })
      ).to.be.revertedWith("Not enough ETH");
    });

    it("Try to mint a new hero with invalid attack points", async () => {
      const emptyWeapons = [0, 0, 0];
      await expect(
        characterContractInstance.mintHero(
          1,
          51,
          emptyWeapons,
          ethers.utils.parseEther("0.08"),
          101
        )
      ).to.be.revertedWith("Invalid _attackPoints");
    });

    it("Try to mint a new hero with invalid armor points", async () => {
      const emptyWeapons = [0, 0, 0];
      await expect(
        characterContractInstance.mintHero(
          101,
          40,
          emptyWeapons,
          ethers.utils.parseEther("0.08"),
          101
        )
      ).to.be.revertedWith("Invalid _armorPoints");
    });

    it("Try to mint a new hero with invalid sell price", async () => {
      const emptyWeapons = [0, 0, 0];
      await expect(
        characterContractInstance.mintHero(
          101,
          51,
          emptyWeapons,
          ethers.utils.parseEther("0"),
          101
        )
      ).to.be.revertedWith("Invalid _sellPrice");
    });

    it("Try to mint a new hero with invalid required experience", async () => {
      const emptyWeapons = [0, 0, 0];
      await expect(
        characterContractInstance.mintHero(
          101,
          51,
          emptyWeapons,
          ethers.utils.parseEther("0.08"),
          99
        )
      ).to.be.revertedWith("Invalid _requiredExperience");
    });

    it("Try to mint a new hero with a non-owner account", async () => {
      const emptyWeapons = [0, 0, 0];
      await expect(
        characterContractInstance
          .connect(account2)
          .mintHero(101, 51, emptyWeapons, ethers.utils.parseEther("0.08"), 101)
      ).to.be.revertedWith("Not the owner");
    });

    it("Mint a new hero", async () => {
      const attackPoints = 101;
      const armorPoints = 51;
      const requiredExperience = 101;
      const sellPrice = ethers.utils.parseEther("0.08");
      const emptyWeapons = [0, 0, 0];
      const totalSupply_before = await characterContractInstance.totalSupply();
      const signerBalance_before = await characterContractInstance.balanceOf(
        signer.address
      );

      const tx = await characterContractInstance.mintHero(
        attackPoints,
        armorPoints,
        emptyWeapons,
        sellPrice,
        requiredExperience
      );
      await tx.wait(confirmations_number);

      const totalSupply_after = await characterContractInstance.totalSupply();
      const signerBalance_after = await characterContractInstance.balanceOf(
        signer.address
      );
      const ownerOf_after = await characterContractInstance.ownerOf(
        totalSupply_after
      );
      expect(totalSupply_after).to.be.equals(totalSupply_before.add(1));
      expect(signerBalance_after).to.be.equals(signerBalance_before.add(1));
      expect(ownerOf_after).to.be.equals(signer.address);
    });

    it("After minting a new hero validate metadata", async () => {
      const attackPoints = 101;
      const armorPoints = 51;
      const requiredExperience = 101;
      const sellPrice = ethers.utils.parseEther("0.08");
      const totalSupply = await characterContractInstance.totalSupply();
      const mintedCharacterMetadata =
        await characterContractInstance.metadataOf(totalSupply);
      const [weapon1, weapon2, weapon3] = mintedCharacterMetadata.weapon;

      expect(mintedCharacterMetadata.attackPoints).to.be.equals(attackPoints);
      expect(mintedCharacterMetadata.armorPoints).to.be.equals(armorPoints);
      expect(mintedCharacterMetadata.requiredExperience).to.be.equals(
        requiredExperience
      );
      expect(mintedCharacterMetadata.sellPrice).to.be.equals(sellPrice);
      expect(mintedCharacterMetadata.onSale).to.be.equals(true);
      expect(weapon1).to.be.equals(0);
      expect(weapon2).to.be.equals(0);
      expect(weapon3).to.be.equals(0);
    });
  });

  describe("Transfers test", () => {
    it("Try to transfer a character with invalid tokenId", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      await expect(
        characterContractInstance.safeTransfer(
          account2.address,
          totalSupply.add(1)
        )
      ).to.be.revertedWith("Invalid tokenId");
    });

    it("Try to transfer a character with invalid _to address", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      await expect(
        characterContractInstance.safeTransfer(zeroAddress, totalSupply)
      ).to.be.revertedWith("Invalid address");
    });

    it("Try to transfer a character with another account", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      await expect(
        characterContractInstance
          .connect(account2)
          .safeTransfer(account1.address, totalSupply)
      ).to.be.revertedWith("Not the owner");
    });

    it("Transfer a character with signer account", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      const signerBalance_before = await characterContractInstance.balanceOf(
        signer.address
      );
      const account3Balance_before = await characterContractInstance.balanceOf(
        account3.address
      );

      await characterContractInstance
        .connect(signer)
        .safeTransfer(account3.address, totalSupply);

      const signerBalance_after = await characterContractInstance.balanceOf(
        signer.address
      );
      const account3Balance_after = await characterContractInstance.balanceOf(
        account3.address
      );

      expect(signerBalance_after).to.be.equals(signerBalance_before.sub(1));
      expect(account3Balance_after).to.be.equals(account3Balance_before.add(1));
    });

    it("Transfer from account3 to account2", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      const account3Balance_before = await characterContractInstance.balanceOf(
        account3.address
      );
      const account2Balance_before = await characterContractInstance.balanceOf(
        account2.address
      );

      await characterContractInstance
        .connect(account3)
        .safeTransfer(account2.address, totalSupply);

      const account3Balance_after = await characterContractInstance.balanceOf(
        account3.address
      );
      const account2Balance_after = await characterContractInstance.balanceOf(
        account2.address
      );

      expect(account3Balance_after).to.be.equals(account3Balance_before.sub(1));
      expect(account2Balance_after).to.be.equals(account2Balance_before.add(1));
    });
  });

  describe("Sales test", () => {
    it("Try to put on sale a character with invalid tokenId", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      await expect(
        characterContractInstance.setOnSale(totalSupply.add(1), 0)
      ).to.be.revertedWith("Invalid tokenId");
    });

    it("Try to put on sale a character with another account", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      await expect(
        characterContractInstance.connect(account3).setOnSale(totalSupply, true)
      ).to.be.revertedWith("Not authorized");
    });

    it("Put on sale a character with correct account", async () => {
      const totalSupply = await characterContractInstance.totalSupply();

      await characterContractInstance
        .connect(account2)
        .setOnSale(totalSupply, true);

      const [onsSaleValue] = await characterContractInstance.getSellinformation(
        totalSupply
      );

      expect(onsSaleValue).to.be.equals(true);
    });

    it("Try to get sale information of a character with invalid tokenId", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      await expect(
        characterContractInstance.getSellinformation(totalSupply.add(1))
      ).to.be.revertedWith("Invalid tokenId");
    });
  });

  describe("Buy test", () => {
    it("Try to buy a character with invalid price", async () => {
      const tokenId = (await characterContractInstance.totalSupply()) - 1;
      await expect(
        characterContractInstance.buy(tokenId, {
          value: ethers.utils.parseEther("0.03"),
        })
      ).to.be.revertedWith("Not enough ETH");
    });

    it("Try to buy a character with invalid tokenId", async () => {
      const tokenId = (await characterContractInstance.totalSupply()) + 3;
      await expect(
        characterContractInstance.buy(tokenId, "New Character Name", {
          value: ethers.utils.parseEther("0.03"),
        })
      ).to.be.revertedWith("Invalid tokenId");
    });

    it("Try to buy a character that is not on sale", async () => {
      const tokenId = await characterContractInstance.totalSupply();
      await characterContractInstance
        .connect(account2)
        .setOnSale(tokenId, false);

      await expect(
        characterContractInstance
          .connect(account3)
          .buy(tokenId, "New Character Name", {
            value: ethers.utils.parseEther("0.08"),
          })
      ).to.be.revertedWith("Character not on sale");
    });

    it("Try to buy a character with inssuficient Experience", async () => {
      const tokenId = await characterContractInstance.totalSupply();
      await characterContractInstance
        .connect(account2)
        .setOnSale(tokenId, true);

      await expect(
        characterContractInstance
          .connect(account3)
          .buy(tokenId, "New Character Name", {
            value: ethers.utils.parseEther("0.08"),
          })
      ).to.be.revertedWith("Insufficient experience");
    });

    it("Buy a character with correct parameters", async () => {
      // Buy Rubies for buying experience
      await rubieContractInstance
        .connect(account3)
        .buy(200, { value: ethers.utils.parseEther("0.0002") });
      expect(
        await rubieContractInstance.balanceOf(account3.address)
      ).to.be.equals(200);

      // Approve the rubies
      await rubieContractInstance
        .connect(account3)
        .approve(experienceContractInstance.address, 200);

      await experienceContractInstance.connect(account3).buy(200);
      expect(
        await experienceContractInstance.balanceOf(account3.address)
      ).to.be.equals(200);

      const tokenId = await characterContractInstance.totalSupply();
      const accoun3ETHBalance_before = await provider.getBalance(
        account3.address
      );

      const tx = await characterContractInstance
        .connect(account3)
        .buy(tokenId, "New Character Name", {
          value: ethers.utils.parseEther("0.08"),
        });
      const tx_receipt = await tx.wait(confirmations_number);

      const _gas = tx_receipt.cumulativeGasUsed;
      const _gasPrice = tx_receipt.effectiveGasPrice;
      const _gasPaid = _gas.mul(_gasPrice);

      const actualOwner = await characterContractInstance.ownerOf(tokenId);
      const account3Balance = await characterContractInstance.balanceOf(
        account3.address
      );
      const account3ETHBalance_after = await provider.getBalance(
        account3.address
      );

      expect(actualOwner).to.be.equals(account3.address);
      expect(account3Balance).to.be.equals(1);
      expect(account3ETHBalance_after).to.be.equals(
        accoun3ETHBalance_before
          .sub(ethers.utils.parseEther("0.08"))
          .sub(_gasPaid)
      );
    });
  });

  describe("Weapon-Character interaction tests", () => {
    before(async () => {
      // Mint Rubies for signer account
      await rubieContractInstance.buy(1574, {
        value: ethers.utils.parseEther("1"),
      });
      // Approve the rubies
      await rubieContractInstance.approve(weaponContractInstance.address, 2000);

      // Mint weapons
      await weaponContractInstance.safeMint("Weapon 1");
      const mintedWeapon1_tokenId = await weaponContractInstance.totalSupply();
      // Put minted weapon on sale
      await weaponContractInstance.setOnSale(mintedWeapon1_tokenId, true);

      await weaponContractInstance.safeMint("Weapon 2");
      const mintedWeapon2_tokenId = await weaponContractInstance.totalSupply();
      // Put minted weapon on sale
      await weaponContractInstance.setOnSale(mintedWeapon2_tokenId, true);

      await weaponContractInstance.mintLegendaryWeapon(
        155,
        200,
        ethers.utils.parseEther("0.04"),
        20
      );
      const mintedWeapon3_tokenId = await weaponContractInstance.totalSupply();
      // Put minted weapon on sale
      await weaponContractInstance.setOnSale(mintedWeapon3_tokenId, true);

      // Mint a new character
      await characterContractInstance
        .connect(account4)
        .safeMint("Character 4", {
          value: ethers.utils.parseEther("0.005"),
        });
      const mintedCharacter_tokenId =
        await characterContractInstance.totalSupply();

      // Buy more rubies for the account4
      await rubieContractInstance
        .connect(account4)
        .buy(4000, { value: ethers.utils.parseEther("0.5") });

      // Before buying the experience approve the contract to spend the rubies
      await rubieContractInstance
        .connect(account4)
        .approve(experienceContractInstance.address, 0);
      await rubieContractInstance
        .connect(account4)
        .approve(experienceContractInstance.address, 1250);
      // Buy experience to buy the 3 weapons
      await experienceContractInstance.connect(account4).buy(1250);

      // Approve weapon contract to spend the rubies of account4
      await rubieContractInstance
        .connect(account4)
        .approve(weaponContractInstance.address, 2000);

      // With account4 buy the 3 weapons
      await weaponContractInstance
        .connect(account4)
        .buy(mintedWeapon1_tokenId, "New Weapon Name 1");

      await weaponContractInstance
        .connect(account4)
        .buy(mintedWeapon2_tokenId, "New Weapon Name 2");

      await weaponContractInstance
        .connect(account4)
        .buy(mintedWeapon3_tokenId, "New Weapon Name 3");

      // Equip the 3 weapons
      await weaponContractInstance
        .connect(account4)
        .addWeaponToCharacter(mintedWeapon1_tokenId, mintedCharacter_tokenId);
      await weaponContractInstance
        .connect(account4)
        .addWeaponToCharacter(mintedWeapon2_tokenId, mintedCharacter_tokenId);
      await weaponContractInstance
        .connect(account4)
        .addWeaponToCharacter(mintedWeapon3_tokenId, mintedCharacter_tokenId);

      console.log(mintedCharacter_tokenId);
    });

    it("Try to get the weapons of a character with invalid tokenId", async () => {
      const totalSupply = await characterContractInstance.totalSupply();
      await expect(
        characterContractInstance.weapon(totalSupply.add(1), totalSupply)
      ).to.be.revertedWith("Invalid _weaponIndex");
    });

    it("Get weapon equipped weapon from an index", async () => {
      const characterTokenId = await characterContractInstance.totalSupply();
      const weapon1 = await characterContractInstance.weapon(
        0,
        characterTokenId
      );
      const weapon2 = await characterContractInstance.weapon(
        1,
        characterTokenId
      );
      const weapon3 = await characterContractInstance.weapon(
        2,
        characterTokenId
      );

      expect(weapon1).to.be.equals(3);
      expect(weapon2).to.be.equals(2);
      expect(weapon3).to.be.equals(1);
    });
  });

  describe("Collect Fees tests", () => {
    it("Try to call collectFees from another contract that is not the owners contract", async () => {
      await expect(characterContractInstance.collectFee()).to.be.revertedWith(
        "Not owners contract"
      );
    });

    it("Call collect fees from owners contract", async () => {
      await ownersContractInstance.collectFeeFromContract("Character");
      expect(
        await ownersContractInstance.collectFeeFromContract("Character")
      ).to.be.revertedWith("zero balance");
    });
  });
});

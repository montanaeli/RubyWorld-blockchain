const { ethers } = require("hardhat");

const chai = require("chai");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);
const { expect } = chai;

const zeroAddress = ethers.constants.AddressZero;
const contractPath = "src/contracts/Rubie.sol:Rubie";
const contractPathCharacter = "src/contracts/Character.sol:Character";

const name = "Rubie Contract";
const symbol = "rub";

let ownerAddress;
let ownersContract;
let rubieContract;

describe("Rubie tests", () => {
  before(async () => {
    [signer, account1, account2, account3] = await ethers.getSigners();
    provider = ethers.provider;

    ownerAddress = signer.address;

    const ownersContractFactory = await ethers.getContractFactory(
      "src/contracts/OwnersContract.sol:OwnersContract",
      signer
    );

    ownersContract = await ownersContractFactory.deploy(10);

    [signer, account1, account2].forEach((account) => {
      ownersContract.addOwner(account.address);
    });

    const rubieContractFactory = await ethers.getContractFactory(
      contractPath,
      signer
    );

    rubieContract = await rubieContractFactory.deploy(
      name,
      symbol,
      ownersContract.address
    );

    await rubieContract.setPrice(1);
  });

  describe("Initalization reverts", () => {
    it("Should revert if the owner address is zero address", async () => {
      const contractFactory = await ethers.getContractFactory(
        contractPath,
        signer
      );

      await expect(
        contractFactory.deploy(name, symbol, zeroAddress)
      ).to.be.revertedWith("Invalid address");
    });
    it("Should revert if the name is empty", async () => {
      const contractFactory = await ethers.getContractFactory(
        contractPath,
        signer
      );

      await expect(
        contractFactory.deploy("", symbol, ownerAddress)
      ).to.be.revertedWith("Invalid name");
    });
    it("Should revert if the symbol length is not 3", async () => {
      const contractFactory = await ethers.getContractFactory(
        contractPath,
        signer
      );

      await expect(
        contractFactory.deploy(name, "abcd", ownerAddress)
      ).to.be.revertedWith("Invalid symbol");
    });
  });

  describe("Constructor initalizations", () => {
    it("Should have the correct name", async () => {
      expect(await rubieContract.name()).to.equal(name);
    });

    it("Should have the correct symbol", async () => {
      expect(await rubieContract.symbol()).to.equal(symbol);
    });

    it("Should have the correct owner", async () => {
      expect(await rubieContract.ownersContract()).to.equal(
        ownersContract.address
      );
    });
  });

  describe("Empty getters", () => {
    it("Should return empty totalSupply", async () => {
      expect(await rubieContract.totalSupply()).to.equal(0);
    });

    it("Should return empty balanceOf", async () => {
      expect(await rubieContract.balanceOf(ownerAddress)).to.equal(0);
    });

    it("Should return empty allowance", async () => {
      expect(
        await rubieContract.allowance(ownerAddress, account1.address)
      ).to.equal(0);
    });
    it("Should return empty price", async () => {
      expect(await rubieContract.price()).to.equal(1);
    });

    it("Should return empty decimals", async () => {
      expect(await rubieContract.decimals()).to.equal(0);
    });
  });

  describe("Intitalization tests", () => {
    it("Should have the correct price", async () => {
      expect(await rubieContract.price()).to.equal(1);
    });
  });
  describe("Method buy", () => {
    it("Should buy rubies", async () => {
      await rubieContract.buy(10, { value: 10 });
      expect(await rubieContract.balanceOf(ownerAddress)).to.equal(10);
    });
    it("Should revert if there's no enough ethers", async () => {
      await expect(rubieContract.buy(10, { value: 0 })).to.be.revertedWith(
        "Insufficient ether"
      );
    });
  });

  describe("Method setPrice", () => {
    it("Should set the price", async () => {
      const price = ethers.utils.parseEther("1");
      await rubieContract.setPrice(price);
      expect(await rubieContract.price()).to.equal(price);
    });
    it("Should revert if the price is zero", async () => {
      await expect(rubieContract.setPrice(0)).to.be.revertedWith(
        "Invalid _price"
      );
    });
    it("Should revert if the sender is not the owner", async () => {
      await expect(
        rubieContract.connect(account3).setPrice(ethers.utils.parseEther("1"))
      ).to.be.revertedWith("Not the owner");
    });
  });

  describe("Method approve", () => {
    it("Should approve 1 tokens", async () => {
      const amount = ethers.utils.parseEther("1");
      await rubieContract.buy(amount, { value: amount });
      await rubieContract.approve(account1.address, amount);
      expect(
        await rubieContract.allowance(ownerAddress, account1.address)
      ).to.equal(amount);
    });
    it("Should revert if the amount is already set", async () => {
      const amount = ethers.utils.parseEther("1");
      await expect(
        rubieContract.approve(account1.address, amount)
      ).to.be.revertedWith("Invalid allowance amount. Set to zero first");
    });
    it("Should approve 0 tokens", async () => {
      await rubieContract.approve(account1.address, 0);
      expect(
        await rubieContract.allowance(ownerAddress, account1.address)
      ).to.equal(0);
    });
    it("Should revert if the sender address is zero address", async () => {
      await expect(
        rubieContract.approve(zeroAddress, ethers.utils.parseEther("1"))
      ).to.be.revertedWith("Invalid _spender");
    });
    it("Should revert if the sender does not have enough tokens", async () => {
      await expect(
        rubieContract.approve(account1.address, ethers.utils.parseEther("2"))
      ).to.be.revertedWith("Insufficient balance");
    });
  });

  describe("Method transfer", () => {
    it("Should transfer 1 tokens and remove allowance", async () => {
      const amount = ethers.utils.parseEther("1");
      await rubieContract.approve(account1.address, amount);
      await rubieContract.transfer(account1.address, amount);
      expect(await rubieContract.balanceOf(account1.address)).to.equal(amount);
      expect(await rubieContract.balanceOf(ownerAddress)).to.equal(10);
      await rubieContract.approve(account1.address, 0);
      expect(
        await rubieContract.allowance(ownerAddress, account1.address)
      ).to.equal(0);
    });
    it("Should revert if the recipient address is zero address", async () => {
      await expect(rubieContract.transfer(zeroAddress, 0)).to.be.revertedWith(
        "Invalid address"
      );
    });
    it("Should revert if recipient is same as remitter", async () => {
      await expect(rubieContract.transfer(ownerAddress, 0)).to.be.revertedWith(
        "Invalid recipient, same as remitter"
      );
    });
    it("Should revert if value is zero", async () => {
      await expect(
        rubieContract.transfer(account1.address, 0)
      ).to.be.revertedWith("Invalid _value");
    });
    it("Should revert if the balance is insufficient", async () => {
      await expect(
        rubieContract.transfer(account1.address, ethers.utils.parseEther("1"))
      ).to.be.revertedWith("Insufficient balance");
    });
  });

  describe("Method transferFrom", async () => {
    it("Should transfer 1 tokens", async () => {
      const amount = ethers.utils.parseEther("1");
      await rubieContract.connect(account1).approve(account2.address, amount);
      await rubieContract.transferFrom(
        account1.address,
        account2.address,
        amount
      );
      expect(await rubieContract.balanceOf(account2.address)).to.equal(amount);
      expect(await rubieContract.balanceOf(account1.address)).to.equal(0);
      await rubieContract.connect(account1).approve(account1.address, 0);
      expect(
        await rubieContract.allowance(ownerAddress, account1.address)
      ).to.equal(0);
    });
    it("Should revert if the sender address is zero address", async () => {
      await expect(
        rubieContract.transferFrom(zeroAddress, ownerAddress, 0)
      ).to.be.revertedWith("Invalid _from address");
    });
    it("Should revert if recipient is same as remitter", async () => {
      await expect(
        rubieContract.transferFrom(ownerAddress, ownerAddress, 0)
      ).to.be.revertedWith("Invalid recipient, same as remitter");
    });
    it("Should revert if the remitter address is zero address", async () => {
      await expect(
        rubieContract.transferFrom(ownerAddress, zeroAddress, 0)
      ).to.be.revertedWith("Invalid _to address");
    });
    it("Should revert if value is zero", async () => {
      await expect(
        rubieContract.transferFrom(account1.address, ownerAddress, 0)
      ).to.be.revertedWith("Invalid _value");
    });
    it("Should revert if the balance is insufficient", async () => {
      await expect(
        rubieContract.transferFrom(
          account1.address,
          ownerAddress,
          ethers.utils.parseEther("1")
        )
      ).to.be.revertedWith("Insufficient balance");
    });
    it("Should revert if the allowance is insufficient", async () => {
      await expect(
        rubieContract.transferFrom(
          account2.address,
          account3.address,
          ethers.utils.parseEther("1")
        )
      ).to.be.revertedWith("Insufficent allowance");
    });
    it("Should transfer tokens even if the allowance isn't enough because the remitter is the owner of the token", async () => {
      await rubieContract
        .connect(account2)
        .transferFrom(
          account2.address,
          account3.address,
          ethers.utils.parseEther("1")
        );
      expect(await rubieContract.balanceOf(account3.address)).to.equal(
        ethers.utils.parseEther("1")
      );
      expect(await rubieContract.balanceOf(account2.address)).to.equal(0);
      expect(
        await rubieContract.allowance(account2.address, account3.address)
      ).to.equal(0);
    });
  });
});

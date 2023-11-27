const { ethers } = require("hardhat");

const chai = require("chai");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);
const { expect } = chai;

const zeroAddress = ethers.constants.AddressZero;
const contractPath = "src/contracts/ERC20.sol:ERC20";

const name = "ERC20 Contract";
const symbol = "e20";

let ownerAddress;
let erc20Contract;
let ownersContract;

describe("ERC20 tests", () => {
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

    const erc20ContractFactory = await ethers.getContractFactory(
      contractPath,
      signer
    );

    erc20Contract = await erc20ContractFactory.deploy(
      name,
      symbol,
      ownersContract.address
    );
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
      expect(await erc20Contract.name()).to.equal(name);
    });

    it("Should have the correct symbol", async () => {
      expect(await erc20Contract.symbol()).to.equal(symbol);
    });

    it("Should have the correct owner", async () => {
      expect(await erc20Contract.ownersContract()).to.equal(
        ownersContract.address
      );
    });
  });

  describe("Empty getters", () => {
    it("Should return empty totalSupply", async () => {
      expect(await erc20Contract.totalSupply()).to.equal(10000000000);
    });

    it("Should return empty balanceOf", async () => {
      expect(await erc20Contract.balanceOf(ownerAddress)).to.equal(0);
    });

    it("Should return empty allowance", async () => {
      expect(
        await erc20Contract.allowance(ownerAddress, account1.address)
      ).to.equal(0);
    });
    it("Should return empty price", async () => {
      expect(await erc20Contract.price()).to.equal(0);
    });

    it("Should return empty decimals", async () => {
      expect(await erc20Contract.decimals()).to.equal(0);
    });
  });

  describe("Method setPrice", () => {
    it("Should set the price", async () => {
      const price = ethers.utils.parseEther("1");
      await erc20Contract.setPrice(price);
      expect(await erc20Contract.price()).to.equal(price);
    });
    it("Should revert if the price is zero", async () => {
      await expect(erc20Contract.setPrice(0)).to.be.revertedWith(
        "Invalid _price"
      );
    });
    it("Should revert if the sender is not the owner", async () => {
      await expect(
        erc20Contract.connect(account3).setPrice(ethers.utils.parseEther("1"))
      ).to.be.revertedWith("Not the owner");
    });
  });

  describe("Method mint", () => {
    it("Should mint tokens", async () => {
      const amount = ethers.utils.parseEther("1");
      await erc20Contract.mint(amount, ownerAddress);
      expect(await erc20Contract.balanceOf(ownerAddress)).to.equal(amount);
    });
    it("Should revert if the amount is zero", async () => {
      await expect(erc20Contract.mint(0, ownerAddress)).to.be.revertedWith(
        "Invalid _amount"
      );
    });
    it("Should revert if the sender is not the owner", async () => {
      await expect(
        erc20Contract
          .connect(account3)
          .mint(ethers.utils.parseEther("1"), ownerAddress)
      ).to.be.revertedWith("Not the owner");
    });
    it("Should revert if the recipient is zero address", async () => {
      await expect(
        erc20Contract.mint(ethers.utils.parseEther("1"), zeroAddress)
      ).to.be.revertedWith("Invalid _recipient");
    });
  });

  describe("Method approve", () => {
    it("Should approve 1 tokens", async () => {
      const amount = ethers.utils.parseEther("1");
      await erc20Contract.approve(account1.address, amount);
      expect(
        await erc20Contract.allowance(ownerAddress, account1.address)
      ).to.equal(amount);
    });
    it("Should revert if the amount is already set", async () => {
      const amount = ethers.utils.parseEther("1");
      await expect(
        erc20Contract.approve(account1.address, amount)
      ).to.be.revertedWith("Invalid allowance amount. Set to zero first");
    });
    it("Should approve 0 tokens", async () => {
      await erc20Contract.approve(account1.address, 0);
      expect(
        await erc20Contract.allowance(ownerAddress, account1.address)
      ).to.equal(0);
    });
    it("Should revert if the sender address is zero address", async () => {
      await expect(
        erc20Contract.approve(zeroAddress, ethers.utils.parseEther("1"))
      ).to.be.revertedWith("Invalid _spender");
    });
    it("Should revert if the sender does not have enough tokens", async () => {
      await expect(
        erc20Contract.approve(account1.address, ethers.utils.parseEther("2"))
      ).to.be.revertedWith("Insufficient balance");
    });
  });

  describe("Method transfer", () => {
    it("Should transfer 1 tokens and remove allowance", async () => {
      const amount = ethers.utils.parseEther("1");
      await erc20Contract.approve(account1.address, amount);
      await erc20Contract.transfer(account1.address, amount);
      expect(await erc20Contract.balanceOf(account1.address)).to.equal(amount);
      expect(await erc20Contract.balanceOf(ownerAddress)).to.equal(0);
      await erc20Contract.approve(account1.address, 0);
      expect(
        await erc20Contract.allowance(ownerAddress, account1.address)
      ).to.equal(0);
    });
    it("Should revert if the recipient address is zero address", async () => {
      await expect(erc20Contract.transfer(zeroAddress, 0)).to.be.revertedWith(
        "Invalid address"
      );
    });
    it("Should revert if recipient is same as remitter", async () => {
      await expect(erc20Contract.transfer(ownerAddress, 0)).to.be.revertedWith(
        "Invalid recipient, same as remitter"
      );
    });
    it("Should revert if value is zero", async () => {
      await expect(
        erc20Contract.transfer(account1.address, 0)
      ).to.be.revertedWith("Invalid _value");
    });
    it("Should revert if the balance is insufficient", async () => {
      await expect(
        erc20Contract.transfer(account1.address, ethers.utils.parseEther("1"))
      ).to.be.revertedWith("Insufficient balance");
    });
  });

  describe("Method transferFrom", async () => {
    it("Should transfer 1 tokens", async () => {
      const amount = ethers.utils.parseEther("1");
      await erc20Contract.connect(account1).approve(account2.address, amount);
      await erc20Contract.transferFrom(
        account1.address,
        account2.address,
        amount
      );
      expect(await erc20Contract.balanceOf(account2.address)).to.equal(amount);
      expect(await erc20Contract.balanceOf(account1.address)).to.equal(0);
      await erc20Contract.connect(account1).approve(account1.address, 0);
      expect(
        await erc20Contract.allowance(ownerAddress, account1.address)
      ).to.equal(0);
    });
    it("Should revert if the sender address is zero address", async () => {
      await expect(
        erc20Contract.transferFrom(zeroAddress, ownerAddress, 0)
      ).to.be.revertedWith("Invalid _from address");
    });
    it("Should revert if recipient is same as remitter", async () => {
      await expect(
        erc20Contract.transferFrom(ownerAddress, ownerAddress, 0)
      ).to.be.revertedWith("Invalid recipient, same as remitter");
    });
    it("Should revert if the remitter address is zero address", async () => {
      await expect(
        erc20Contract.transferFrom(ownerAddress, zeroAddress, 0)
      ).to.be.revertedWith("Invalid _to address");
    });
    it("Should revert if value is zero", async () => {
      await expect(
        erc20Contract.transferFrom(account1.address, ownerAddress, 0)
      ).to.be.revertedWith("Invalid _value");
    });
    it("Should revert if the balance is insufficient", async () => {
      await expect(
        erc20Contract.transferFrom(
          account1.address,
          ownerAddress,
          ethers.utils.parseEther("1")
        )
      ).to.be.revertedWith("Insufficient balance");
    });
    it("Should revert if the allowance is insufficient", async () => {
      await expect(
        erc20Contract.transferFrom(
          account2.address,
          account3.address,
          ethers.utils.parseEther("1")
        )
      ).to.be.revertedWith("Insufficent allowance");
    });
    it("Should transfer tokens even if the allowance isn't enough because the remitter is the owner of the token", async () => {
      await erc20Contract
        .connect(account2)
        .transferFrom(
          account2.address,
          account3.address,
          ethers.utils.parseEther("1")
        );
      expect(await erc20Contract.balanceOf(account3.address)).to.equal(
        ethers.utils.parseEther("1")
      );
      expect(await erc20Contract.balanceOf(account2.address)).to.equal(0);
      expect(
        await erc20Contract.allowance(account2.address, account3.address)
      ).to.equal(0);
    });
  });
});

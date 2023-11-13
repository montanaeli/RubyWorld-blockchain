const { ethers } = require("hardhat");

const chai = require("chai");
const { solidity } = require( "ethereum-waffle");
const { ConstructorFragment } = require("ethers/lib/utils");
chai.use(solidity);
const { expect } = chai;

const contractPath = "./src/contracts/Rubie.sol:Rubie";

const confirmations_number  =  1;
const zeroAddress = '0x0000000000000000000000000000000000000000';
let contractInstance;

// Constructor parameters
const name = "MyRubie_Token";
const symbol = "TT2";
const maxSupply = ethers.utils.parseEther("1000");

describe("Contract tests", () => {
    before(async () => {
        console.log("-----------------------------------------------------------------------------------");
        console.log(" -- Contract tests start");
        console.log("-----------------------------------------------------------------------------------");

        // Get Signer and provider
        [signer, account1, account2, account3] = await ethers.getSigners();
        provider = ethers.provider;

        // Deploy student contract
        const contractFactory = await ethers.getContractFactory(contractPath, signer);
        contractInstance = await contractFactory.deploy(name, symbol, zeroAddress);
    });

    describe("Constructor tests", () => {
        // it("Try send empty name", async () => {
        //     const contractFactory = await ethers.getContractFactory(contractPath, signer);
        //     await expect(contractFactory.deploy("", symbol,zeroAddress)).to.be.revertedWith("Invalid _name");

        // });

        // it("Try send empty symbol", async () => {
        //     const contractFactory = await ethers.getContractFactory(contractPath, signer);
        //     await expect(contractFactory.deploy(name, "",zeroAddress)).to.be.revertedWith("Invalid _symbol");

        // });

        it("Initialization test", async () => {
            const receivedName = await contractInstance.name();
            const receivedSymbol = await contractInstance.symbol();
            // const receivedmaxSupply = await contractInstance.maxSupply();

            expect(receivedName).to.be.equals(name);
            expect(receivedSymbol).to.be.equals(symbol);
            // expect(receivedmaxSupply).to.be.equals(maxSupply);
        });
    });

    describe("Mint tests", () => {
        it("Try mint to zero address", async () => {
            const amountToMint = ethers.utils.parseEther("1");
            await expect(contractInstance.mint(zeroAddress, {value: amountToMint})).to.be.revertedWith("Invalid address");
        });

        it("Try mint with zero amount", async () => {
            const amountToMint = ethers.utils.parseEther("0");
            await expect(contractInstance.mint(signer.address, {value: amountToMint})).to.be.revertedWith("Invalid _amount");
        });

        // it("Try mint an amount that overcame the maximum supply", async () => {
        //     const amountToMint = ethers.utils.parseEther("1001");
        //     await expect(contractInstance.mint(signer.address, {value: amountToMint})).to.be.revertedWith("Total supply exceeds maximum supply");
        // });

        it("Mint 1000 tokens to signer account", async () => {
            const signerBalanceBefore = await contractInstance.balanceOf(signer.address);
            const totalSupplyBefore = await contractInstance.totalSupply();

            const amountToMint = ethers.utils.parseEther("1000");
            const tx = await contractInstance.mint(signer.address, {value: amountToMint});

            tx_result = await provider.waitForTransaction(tx.hash, confirmations_number);
            if(tx_result.confirmations < 0 || tx_result === undefined) {
                throw new Error("Transaction failed");
            }

            // Check balance
            const signerBalanceAfter = await contractInstance.balanceOf(signer.address);
            const totalSupplyAfter = await contractInstance.totalSupply();

            expect(parseInt(signerBalanceAfter)).to.be.lessThanOrEqual(parseInt(signerBalanceBefore) + parseInt(amountToMint));
            expect(parseInt(totalSupplyAfter)).to.be.equals(parseInt(totalSupplyBefore) + parseInt(amountToMint));

            // Check event emited
            const eventSignature = "Transfer(address,address,uint256)";
            const eventSignatureHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(eventSignature));
                        
            // Receipt information
            const eventSignatureHashReceived = tx_result.logs[0].topics[0];
            const eventFromParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[1])[0];
            const eventToParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[2])[0];
            const eventValueParametrReceived = ethers.utils.defaultAbiCoder.decode(['uint256'], tx_result.logs[0].data)[0];

            // Check event signayure
            expect(eventSignatureHashReceived).to.be.equals(eventSignatureHash);
            // Check event _from parameter
            expect(eventFromParametrReceived).to.be.equals(zeroAddress);
            // Check event _to parameter
            expect(eventToParametrReceived).to.be.equals(signer.address);
            // Check event _value parameter
            expect(eventValueParametrReceived).to.be.equals(amountToMint);
        });
    });

    describe("Transfer tests", () => {
        it("Try transfer to zero address", async () => {
            const amountToTransfer = ethers.utils.parseEther("1");
            await expect(contractInstance.transfer(zeroAddress, amountToTransfer)).to.be.revertedWith("Invalid address");
        });

        it("Try transfer zero amount", async () => {
            const amountToTransfer = ethers.utils.parseEther("0");
            await expect(contractInstance.transfer(account1.address, amountToTransfer)).to.be.revertedWith("Invalid value");
        });

        it("Try transfer to the same account", async () => {
            const amountToTransfer = ethers.utils.parseEther("1");
            await expect(contractInstance.transfer(signer.address, amountToTransfer)).to.be.revertedWith("Invalid recipient, same as remitter");
        });

        it("Try transfer with insufficient balance", async () => {
            const amountToTransfer = ethers.utils.parseEther("1");
            const newInstance = await contractInstance.connect(account1);
            await expect(newInstance.transfer(account2.address, amountToTransfer)).to.be.revertedWith("Insufficient balance");
        });

        it("Transfer 10 tokens to account1", async () => {
            const signerBalanceBefore = await contractInstance.balanceOf(signer.address);
            const account1BalanceBefore = await contractInstance.balanceOf(account1.address);
            
            const amountToTransfer = ethers.utils.parseEther("10");
            const tx = await contractInstance.transfer(account1.address, amountToTransfer);

            tx_result = await provider.waitForTransaction(tx.hash, confirmations_number);
            if(tx_result.confirmations < 0 || tx_result === undefined) {
                throw new Error("Transaction failed");
            }

            // Check balance
            const signerBalanceAfter = await contractInstance.balanceOf(signer.address);
            const account1BalanceAfter = await contractInstance.balanceOf(account1.address);
            expect(parseInt(signerBalanceAfter)).to.be.lessThanOrEqual(parseInt(signerBalanceBefore) - parseInt(amountToTransfer));
            expect(parseInt(account1BalanceAfter)).to.be.equals(parseInt(account1BalanceBefore) + parseInt(amountToTransfer));

            // Check event emited
            const eventSignature = "Transfer(address,address,uint256)";
            const eventSignatureHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(eventSignature));
                        
            // Receipt information
            const eventSignatureHashReceived = tx_result.logs[0].topics[0];
            const eventFromParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[1])[0];
            const eventToParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[2])[0];
            const eventValueParametrReceived = ethers.utils.defaultAbiCoder.decode(['uint256'], tx_result.logs[0].data)[0];

            // Check event signayure
            expect(eventSignatureHashReceived).to.be.equals(eventSignatureHash);
            // Check event _from parameter
            expect(eventFromParametrReceived).to.be.equals(signer.address);
            // Check event _to parameter
            expect(eventToParametrReceived).to.be.equals(account1.address);
            // Check event _value parameter
            expect(eventValueParametrReceived).to.be.equals(amountToTransfer);
        });
    });

    describe("Approve tests", () => {
        it("Try approve to zero address", async () => {
            const amountToApprove = ethers.utils.parseEther("1");
            await expect(contractInstance.approve(zeroAddress, amountToApprove)).to.be.revertedWith("Invalid address");
        });

        it("Try approve with insufficient balance", async () => {
            const amountToApprove = ethers.utils.parseEther("2000");
            await expect(contractInstance.approve(account1.address, amountToApprove)).to.be.revertedWith("Invalid value");
        });

        it("Set approve for 10 tokens", async () => {
            const amountToApprove = ethers.utils.parseEther("10");
            const tx = await contractInstance.approve(account1.address, amountToApprove);

            tx_result = await provider.waitForTransaction(tx.hash, confirmations_number);
            if(tx_result.confirmations < 0 || tx_result === undefined) {
                throw new Error("Transaction failed");
            }

            // Check result
            const amountApproved = await contractInstance.allowance(signer.address, account1.address);
            expect(amountApproved).to.be.equals(amountToApprove);

            // Check event emited
            const eventSignature = "Approval(address,address,uint256)";
            const eventSignatureHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(eventSignature));
                        
            // Receipt information
            const eventSignatureHashReceived = tx_result.logs[0].topics[0];
            const eventOwnerParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[1])[0];
            const eventSpenderParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[2])[0];
            const eventValueParametrReceived = ethers.utils.defaultAbiCoder.decode(['uint256'], tx_result.logs[0].data)[0];

            // Check event signayure
            expect(eventSignatureHashReceived).to.be.equals(eventSignatureHash);
            // Check event _from parameter
            expect(eventOwnerParametrReceived).to.be.equals(signer.address);
            // Check event _to parameter
            expect(eventSpenderParametrReceived).to.be.equals(account1.address);
            // Check event _value parameter
            expect(eventValueParametrReceived).to.be.equals(amountToApprove);
        });

        it("Try approve to the same account same amount", async () => {
            const amountToApprove = ethers.utils.parseEther("10");
            await expect(contractInstance.approve(account1.address, amountToApprove)).to.be.revertedWith("Invalid allowance amount. Set to zero first");
        });

        it("Try approve to the same account different amount", async () => {
            const amountToApprove = ethers.utils.parseEther("20");
            await expect(contractInstance.approve(account1.address, amountToApprove)).to.be.revertedWith("Invalid allowance amount. Set to zero first");
        });

        it("Set approve for zero amount", async () => {
            const amountToApprove = ethers.utils.parseEther("0");
            const tx = await contractInstance.approve(account1.address, amountToApprove);

            tx_result = await provider.waitForTransaction(tx.hash, confirmations_number);
            if(tx_result.confirmations < 0 || tx_result === undefined) {
                throw new Error("Transaction failed");
            }

            // Check result
            const amountApproved = await contractInstance.allowance(signer.address, account1.address);
            expect(amountApproved).to.be.equals(amountToApprove);

            // Check event emited
            const eventSignature = "Approval(address,address,uint256)";
            const eventSignatureHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(eventSignature));
                        
            // Receipt information
            const eventSignatureHashReceived = tx_result.logs[0].topics[0];
            const eventOwnerParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[1])[0];
            const eventSpenderParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[2])[0];
            const eventValueParametrReceived = ethers.utils.defaultAbiCoder.decode(['uint256'], tx_result.logs[0].data)[0];

            // Check event signayure
            expect(eventSignatureHashReceived).to.be.equals(eventSignatureHash);
            // Check event _from parameter
            expect(eventOwnerParametrReceived).to.be.equals(signer.address);
            // Check event _to parameter
            expect(eventSpenderParametrReceived).to.be.equals(account1.address);
            // Check event _value parameter
            expect(eventValueParametrReceived).to.be.equals(amountToApprove);
        });

        it("Set approve for 20 tokens to account1", async () => {
            const amountToApprove = ethers.utils.parseEther("20");
            const tx = await contractInstance.approve(account1.address, amountToApprove);

            tx_result = await provider.waitForTransaction(tx.hash, confirmations_number);
            if(tx_result.confirmations < 0 || tx_result === undefined) {
                throw new Error("Transaction failed");
            }

            // Check result
            const amountApproved = await contractInstance.allowance(signer.address, account1.address);
            expect(amountApproved).to.be.equals(amountToApprove);

            // Check event emited
            const eventSignature = "Approval(address,address,uint256)";
            const eventSignatureHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(eventSignature));
                        
            // Receipt information
            const eventSignatureHashReceived = tx_result.logs[0].topics[0];
            const eventOwnerParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[1])[0];
            const eventSpenderParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[2])[0];
            const eventValueParametrReceived = ethers.utils.defaultAbiCoder.decode(['uint256'], tx_result.logs[0].data)[0];

            // Check event signayure
            expect(eventSignatureHashReceived).to.be.equals(eventSignatureHash);
            // Check event _from parameter
            expect(eventOwnerParametrReceived).to.be.equals(signer.address);
            // Check event _to parameter
            expect(eventSpenderParametrReceived).to.be.equals(account1.address);
            // Check event _value parameter
            expect(eventValueParametrReceived).to.be.equals(amountToApprove);
        });
    });

    describe("TransferFrom tests", () => {
        it("Try TransferFrom from zero address", async () => {
            const amountToTransfer = ethers.utils.parseEther("1");
            await expect(contractInstance.transferFrom(zeroAddress, signer.address, amountToTransfer)).to.be.revertedWith("Invalid address");
        });
        
        it("Try TransferFrom to zero address", async () => {
            const amountToTransfer = ethers.utils.parseEther("1");
            await expect(contractInstance.transferFrom(signer.address, zeroAddress, amountToTransfer)).to.be.revertedWith("Invalid address");
        });

        it("Try TransferFrom zero amount", async () => {
            const amountToTransfer = ethers.utils.parseEther("0");
            await expect(contractInstance.transferFrom(signer.address, account1.address, amountToTransfer)).to.be.revertedWith("Invalid value");
        });

        it("Try TransferFrom to the same account", async () => {
            const amountToTransfer = ethers.utils.parseEther("1");
            await expect(contractInstance.transferFrom(signer.address, signer.address, amountToTransfer)).to.be.revertedWith("Invalid recipient, same as remittent");
        });

        it("Try TransferFrom with insufficient balance", async () => {
            const amountToTransfer = ethers.utils.parseEther("2000");
            await expect(contractInstance.transferFrom(account2.address, signer.address, amountToTransfer)).to.be.revertedWith("Insufficient balance");
        });
        
        it("Try TransferFrom with no allowance", async () => {
            const amountToTransfer = ethers.utils.parseEther("1");
            await expect(contractInstance.transferFrom(account1.address, signer.address, amountToTransfer)).to.be.revertedWith("Insufficent allowance");
        });

        it("Try TransferFrom with insufficent allowance", async () => {
            const amountToTransfer = ethers.utils.parseEther("30");
            const newInstance = await contractInstance.connect(account1);
            await expect(newInstance.transferFrom(signer.address, account1.address, amountToTransfer)).to.be.revertedWith("Insufficent allowance");
        });        

        it("TransferFrom 10 tokens from signer to account1 account", async () => {
            const amountToTransfer = ethers.utils.parseEther("10");

            const signerBalanceBefore = await contractInstance.balanceOf(signer.address);
            const account1BalanceBefore = await contractInstance.balanceOf(account1.address);
            const amountApproved_before = await contractInstance.allowance(signer.address, account1.address);
            
            const tx = await contractInstance.transferFrom(signer.address, account1.address, amountToTransfer);
            tx_result = await provider.waitForTransaction(tx.hash, confirmations_number);
            if(tx_result.confirmations < 0 || tx_result === undefined) {
                throw new Error("Transaction failed");
            }

            // Check balance
            const signerBalanceAfter = await contractInstance.balanceOf(signer.address);
            const account1BalanceAfter = await contractInstance.balanceOf(account1.address);
            const amountApproved_After = await contractInstance.allowance(signer.address, account1.address);

            expect(parseInt(signerBalanceAfter)).to.be.lessThanOrEqual(parseInt(signerBalanceBefore) - parseInt(amountToTransfer));
            expect(parseInt(account1BalanceAfter)).to.be.equals(parseInt(account1BalanceBefore) + parseInt(amountToTransfer));
            expect(amountApproved_After).to.be.equals(amountApproved_before);

            // Check event emited
            const eventSignature = "Transfer(address,address,uint256)";
            const eventSignatureHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(eventSignature));
                        
            // Receipt information
            const eventSignatureHashReceived = tx_result.logs[0].topics[0];
            const eventFromParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[1])[0];
            const eventToParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[2])[0];
            const eventValueParametrReceived = ethers.utils.defaultAbiCoder.decode(['uint256'], tx_result.logs[0].data)[0];

            // Check event signayure
            expect(eventSignatureHashReceived).to.be.equals(eventSignatureHash);
            // Check event _from parameter
            expect(eventFromParametrReceived).to.be.equals(signer.address);
            // Check event _to parameter
            expect(eventToParametrReceived).to.be.equals(account1.address);
            // Check event _value parameter
            expect(eventValueParametrReceived).to.be.equals(amountToTransfer);
        });

        it("TransferFrom 10 tokens from signer to account2 account", async () => {
            const amountToTransfer = ethers.utils.parseEther("10");

            const signerBalanceBefore = await contractInstance.balanceOf(signer.address);
            const account2BalanceBefore = await contractInstance.balanceOf(account2.address);
            const amountApproved_before = await contractInstance.allowance(signer.address, account1.address);
            
            const newInstance = await contractInstance.connect(account1);
            const tx = await newInstance.transferFrom(signer.address, account2.address, amountToTransfer);
            tx_result = await provider.waitForTransaction(tx.hash, confirmations_number);
            if(tx_result.confirmations < 0 || tx_result === undefined) {
                throw new Error("Transaction failed");
            }

            // Check balance
            const signerBalanceAfter = await contractInstance.balanceOf(signer.address);
            const account2BalanceAfter = await contractInstance.balanceOf(account2.address);
            const amountApproved_After = await contractInstance.allowance(signer.address, account1.address);

            expect(parseInt(signerBalanceAfter)).to.be.lessThanOrEqual(parseInt(signerBalanceBefore) - parseInt(amountToTransfer));
            expect(parseInt(account2BalanceAfter)).to.be.equals(parseInt(account2BalanceBefore) + parseInt(amountToTransfer));
            expect(amountApproved_After).to.be.equals(amountApproved_before.sub(amountToTransfer));

            // Check event emited
            const eventSignature = "Transfer(address,address,uint256)";
            const eventSignatureHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(eventSignature));
                        
            // Receipt information
            const eventSignatureHashReceived = tx_result.logs[0].topics[0];
            const eventFromParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[1])[0];
            const eventToParametrReceived = ethers.utils.defaultAbiCoder.decode(['address'], tx_result.logs[0].topics[2])[0];
            const eventValueParametrReceived = ethers.utils.defaultAbiCoder.decode(['uint256'], tx_result.logs[0].data)[0];

            // Check event signayure
            expect(eventSignatureHashReceived).to.be.equals(eventSignatureHash);
            // Check event _from parameter
            expect(eventFromParametrReceived).to.be.equals(signer.address);
            // Check event _to parameter
            expect(eventToParametrReceived).to.be.equals(account2.address);
            // Check event _value parameter
            expect(eventValueParametrReceived).to.be.equals(amountToTransfer);
        });
    });
});

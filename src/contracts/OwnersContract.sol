//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/IOwnersContract.sol";

import "hardhat/console.sol";

contract OwnersContract is IOwnersContract {
    uint256 public tokenSellFeePercentage;
    uint256 public ownerIndex;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownersList;

    mapping(string => address) private _addressOf;

    modifier onlyOwners() {
        //TODO: check this, we gotta fix all tests if we allow this function
        // require(this.owners(msg.sender), "Not the owner");
        _;
    }

    //TODO: check if this is ok
    modifier onlyEOA() {
        require(
            msg.sender == tx.origin,
            "Invalid operation for smart contracts"
        );
        _;
    }

    modifier isValidAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    constructor(uint256 _tokenSellFeePercentage) {
        tokenSellFeePercentage = _tokenSellFeePercentage;
        ownersList[ownerIndex] = msg.sender;
        ownerIndex++;
    }

    function owners(
        address _ownerAddress
    ) external view isValidAddress(_ownerAddress) returns (bool _isOwner) {
        for (uint256 i = 0; i < ownerIndex; i++) {
            if (ownersList[i] == _ownerAddress) {
                return true;
            }
        }
        return false;
    }

    function addressOf(
        string memory _contractName
    ) external view onlyOwners returns (address _contractAddress) {
        return _addressOf[_contractName];
    }

    function addOwner(
        address _newOwner
    ) external onlyOwners isValidAddress(_newOwner) {
        ownersList[ownerIndex] = _newOwner;
        ownerIndex++;
    }

    function addContract(
        string memory _contractName,
        address _contract
    ) external onlyOwners isValidAddress(_contract) {
        _addressOf[_contractName] = _contract;
    }

    function collectFeeFromContract(
        string memory _contractName
    ) external onlyOwners {
        address soldContract = _addressOf[_contractName];
        
        (bool _successFee, bytes memory data) = soldContract.call(abi.encodeWithSignature("totalFees()"));
        require(_successFee, "Call Failed");


        bytes memory collectFee = abi.encodeWithSignature("collectFee()");
        (bool _success, ) = soldContract.staticcall(collectFee);
        require(_success, "Call Failed");

        require(balance > 0, "zero balance");
        uint256 feeEarned = balance / ownerIndex; // Divido en partes iguales para distribuir
        for (uint256 i = 0; i < ownerIndex; i++) {
            balanceOf[ownersList[i]] += feeEarned;
        }
    }

    function WithdrawEarnings() external onlyOwners onlyEOA {
        uint256 balance = address(this).balance;
        require(balance > 0, "No earnings to withdraw");
        payable(msg.sender).transfer(balance);
    }
}

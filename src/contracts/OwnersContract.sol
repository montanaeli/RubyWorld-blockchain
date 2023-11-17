//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/IOwnersContract.sol";

// TODO: implement all validations missing.
// TODO: implement implement the las two functions.

contract OwnersContract is IOwnersContract {
    uint256 public tokenSellFeePercentage;
    uint256 public ownerIndex;

    mapping(uint256 => address) public ownersList;
    mapping(address => uint256) public balanceOf;
    mapping(string => address) public addressOf;

    modifier onlyOwners() {
    bool isOwner = false;
    for (uint256 i = 0; i < ownerIndex; i++) {
        if (ownersList[i] == msg.sender) {
            isOwner = true;
            break;
        }
    }
    require(isOwner, "Invalid operation for smart contracts");
    _;
}

    constructor(uint256 _tokenSellFreePercentage) {
        tokenSellFeePercentage = _tokenSellFreePercentage;
        ownerIndex = 0;
    }

    function owners(
        address _ownerAddress
    ) external view returns (bool _isOwner) {
        for (uint256 i = 0; i < ownerIndex; i++) {
            if (ownersList[i] == _ownerAddress) {
                return true;
            }
        }
        return false;
    }

    function addOwner(address _newOwner) external {
        ownersList[ownerIndex] = _newOwner;
        ownerIndex++;
    }

    function addContract(
        string memory _contractName,
        address _contract
    ) external {
        addressOf[_contractName] = _contract;
    }

    function collectFeeFromContract(string memory _contractName) external onlyOwners {
        address soldContract = addressOf[_contractName];
        bytes memory collectFee = abi.encodeWithSignature("collectFee()");
        (bool _success, ) = soldContract.staticcall(collectFee);
        require(_success, "Call Failed");
        uint256 balance = address(this).balance;
        require(balance > 0, "zero balance");
        uint256 fee = balance / ownerIndex;
        for (uint256 i = 0; i < ownerIndex; i++) {
            balanceOf[ownersList[i]] += fee;
        }
    }

    function WithdrawEarnings() external onlyOwners {
        uint256 amount = balanceOf[msg.sender];
        require(amount > 0, "No earnings to withdraw");
        balanceOf[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/IOwnersContract.sol";

/// @dev TODO: implement all validations specified in the Obligatorio document.
/// @dev TODO: implement implement the las two functions.

contract OwnersContract is IOwnersContract {
    uint256 public tokenSellFeePercentage;
    uint256 private lastOwnerIndex;

    // List of Owners
    mapping(uint256 => address) public ownersListMapping;
    mapping(address => uint256) public balances;
    mapping(string => address) public contracts;
    mapping(address => uint256) public feeBalances;

    constructor(uint256 _tokenSellFreePercentage) {
        tokenSellFeePercentage = _tokenSellFreePercentage;
        lastOwnerIndex = 0;
    }

    function ownerIndex() external view returns (uint256 _ownerIndex) {
        return lastOwnerIndex;
    }

    function owners(
        address _ownerAddress
    ) external view returns (bool _isOwner) {
        for (uint256 i = 0; i < lastOwnerIndex; i++) {
            if (ownersListMapping[i] == _ownerAddress) {
                return true;
            }
        }
        return false;
    }

    function ownersList(
        uint256 _ownerIndex
    ) external view returns (address _ownerAddress) {
        return ownersListMapping[_ownerIndex];
    }

    function addressOf(
        string memory _contractName
    ) external view returns (address _contractAddress) {
        return contracts[_contractName];
    }

    function balanceOf(
        address _ownerAddress
    ) external view returns (uint256 _ownerBalance) {
        return balances[_ownerAddress];
    }

    function addOwner(address _newOwner) external {
        ownersListMapping[lastOwnerIndex] = _newOwner;
        lastOwnerIndex++;
    }

    function addContract(
        string memory _contractName,
        address _contract
    ) external {
        contracts[_contractName] = _contract;
    }

    function collectFeeFromContract(string memory _contractName) external {
        // To be implemented
    }

    function WithdrawEarnings() external {
        // To be implemented
    }
}

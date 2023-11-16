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

    constructor(uint256 _tokenSellFreePercentage) {
        tokenSellFeePercentage = _tokenSellFreePercentage;
        ownerIndex = 0;
    }

    function getSellFeePercentage() public view returns (uint256 _tokenSellFeePercentage) {
        return tokenSellFeePercentage;
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

    function collectFeeFromContract(string memory _contractName) external {
        address soldContract = addressOf[_contractName];
        bytes memory collectFee = abi.encodeWithSignature("collectFee()");
        (bool _success, bytes memory _returnData) = soldContract.staticcall(collectFee);
        require(_success, "Call Failed");
    }
    

    function WithdrawEarnings() external {
        //TODO
    }
}

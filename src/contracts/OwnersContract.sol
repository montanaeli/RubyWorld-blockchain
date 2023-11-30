//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/IOwnersContract.sol";
import "src/contracts/Character.sol";

contract OwnersContract is IOwnersContract {
    uint256 public tokenSellFeePercentage;
    uint256 public ownerIndex;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownersList;

    mapping(string => address) private _addressOf;
    mapping(address => bool) private _protocolContracts;

    modifier onlyOwners() {
        require(
            this.owners(msg.sender) || _protocolContracts[msg.sender],
            "Not the owner"
        );
        _;
    }

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

    receive() external payable {}

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
        _protocolContracts[_contract] = true;
    }

    function collectFeeFromContract(
        string memory _contractName
    ) external onlyOwners {
        bytes memory methodToCall = abi.encodeWithSignature("collectFee()");
        (bool success, ) = _addressOf[_contractName].call(methodToCall);
        require(success, "Call Failed");
    }

    function WithdrawEarnings() external onlyOwners onlyEOA {
        uint256 balance = address(this).balance;
        require(balance > 0, "No earnings to withdraw");
        // Distribuir la tarifa ganada a los propietarios en partes iguales
        uint256 feeEarned = balance / ownerIndex;
        for (uint256 i = 0; i < ownerIndex; i++) {
            payable(ownersList[i]).transfer(feeEarned);
        }
    }
}

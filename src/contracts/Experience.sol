//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";
import "./OwnersContract.sol";
import "./Rubie.sol";
import "../interfaces/IRubie.sol";
import "../interfaces/ICharacter.sol";
import "../interfaces/IExperience.sol";
import "../interfaces/IRubie.sol";

contract Experience is IExperience, ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        address _ownersContract
    ) ERC20(_name, _symbol, _ownersContract) {}

    function buy(uint256 _amount) external {
        address rubieContractAddress = OwnersContract(ownersContract).addressOf(
            "Rubie"
        );

        require(
            Rubie(rubieContractAddress).balanceOf(msg.sender) >= _amount,
            "Insufficient balance"
        );

        require(
            this.allowance(msg.sender, address(this)) >= _amount,
            "Insufficient allowance"
        );

        address characterContractAddress = OwnersContract(ownersContract)
            .addressOf("Character");

        ICharacter characterContract = ICharacter(characterContractAddress);

        //TODO: como se obtiene?
        uint256 ownerId = 0;

        uint256 armorPoints = characterContract.metadataOf(ownerId).armorPoints;
        uint256 attackPoints = characterContract
            .metadataOf(ownerId)
            .attackPoints;
        uint256 sellPrice = characterContract.metadataOf(ownerId).sellPrice;

        //TODO: falta hacer las cuentas
        characterContract.setArmorPoints(ownerId, armorPoints);
        characterContract.setAttackPoints(ownerId, attackPoints);
        characterContract.setSellPrice(ownerId, sellPrice);

        emit Transfer(address(this), msg.sender, _amount);
    }
}

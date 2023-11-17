//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";
import "./OwnersContract.sol";
import "./Character.sol";
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

        Character characterContract = Character(characterContractAddress);

        uint256[] memory tokens = characterContract.getTokensOf(msg.sender);

        require(tokens.length == 0, "No character found");

        //TODO: Check with the team, this is wrong
        uint256 tokenId = tokens[0];

        characterContract.upgradeCharacter(
            tokenId,
            characterContract.metadataOf(tokenId).attackPoints +
                ((_amount * 5) / 100),
            characterContract.metadataOf(tokenId).armorPoints +
                ((_amount * 1) / 100),
            (characterContract.metadataOf(tokenId).sellPrice * 11) / 10
        );

        emit Transfer(address(this), msg.sender, _amount);
    }
}

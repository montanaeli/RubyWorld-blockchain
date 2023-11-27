//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";
import "src/interfaces/IRubie.sol";
import "src/interfaces/IOwnersContract.sol";
import "src/interfaces/ICharacter.sol";
import "src/interfaces/IExperience.sol";
import "src/interfaces/IRubie.sol";

contract Experience is IExperience, ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        address _ownersContract
    ) ERC20(_name, _symbol, _ownersContract) {}

    function buy(uint256 _amount) external {
        address rubieContractAddress = IOwnersContract(ownersContract)
            .addressOf("Rubie");

        require(
            IRubie(rubieContractAddress).balanceOf(msg.sender) >= _amount,
            "Insufficient balance"
        );

        //TODO: Not so sure how to bypass this
        // require(
        //     allowance[address(this)][msg.sender] >= _amount,
        //     "Insufficient allowance"
        // );

        address characterContractAddress = IOwnersContract(ownersContract)
            .addressOf("Character");

        uint256 tokenId = ICharacter(characterContractAddress)
            .getCharacterTokenId(msg.sender);

        this.internalTransferFrom(msg.sender, _amount);

        ICharacter(characterContractAddress).setMetadataFromExperience(
            tokenId,
            ICharacter(characterContractAddress)
                .metadataOf(tokenId)
                .attackPoints + ((_amount * 5) / 100),
            ICharacter(characterContractAddress)
                .metadataOf(tokenId)
                .armorPoints + ((_amount * 1) / 100),
            (ICharacter(characterContractAddress)
                .metadataOf(tokenId)
                .sellPrice * 11) / 10
        );

        emit Transfer(address(this), msg.sender, _amount);
    }
}

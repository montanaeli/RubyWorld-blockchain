//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/ICharacter.sol";
import "./ERC721.sol";

abstract contract Character is ICharacter, ERC721 {
    /// @dev Each minted characters will start with 100 attackPoints and 50 armorPoints. The rest of
    /// the attributes will be set to default values.
    /// @dev With each new minted character, the owner account will recieve 1000 RUBIE tokens
    function safeMint(string memory _name) external {}
}

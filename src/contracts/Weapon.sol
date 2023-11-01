//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IWeapon.sol";
import "./ERC721.sol";

abstract contract Weapon is IWeapon, ERC721 {
    /// @dev Each minted weapon will start with 30 attackPoints and 5 armorPoints.
    /// @dev Set sellPrice to mintPrice, requiredExperience to 10 and onSale to false.
    function safeMint(string memory _name) external {}
}

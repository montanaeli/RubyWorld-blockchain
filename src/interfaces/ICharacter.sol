//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IWeapon.sol";
import "./IERC721.sol";

interface ICharacter is IERC721 {
    /// @dev Events

    /// @notice Trigger when tokens are transferred
    /// @dev On new tokens creation, trigger with the `from` address set to zero address
    /// @param _from The address of the sender. This field must be indexed.
    /// @param _to The address of the recipient. This field must be indexed.
    /// @param _value The amount of tokens transferred

    /// @notice Trigger on any successful call to `approve` method
    /// @param _owner The address of the owner. This field must be indexed.
    /// @param _spender The address of the approved spender. This field must be indexed.
    /// @param _value The amount of tokens approved

    // Structure metadata
    struct Metadata {
        string name;
        uint256 attackPoints;
        uint256 armorPoints;
        IWeapon[3] weapon;
        uint256 sellPrice;
        uint256 requiredExperience;
        bool onSale;
    }

    /// @dev Returns the metadata of the character in the indicated index
    function metadataOf(
        uint256 _tokenId
    ) external view returns (Metadata memory _metadata);

    /// @dev Returns the equipped weapon of the character in the indicated index
    function weapon(
        uint256 _weaponIndex
    ) external view returns (IWeapon _weapon);

    /// @notice Mint a new hero, a character NFT with special attributes
    /// @dev Revert if _attackPoints is less than 100 with "Invalid _attackPoints"
    /// @dev Revert if _armorPoints is less than 50 with "Invalid _armorPoints"
    /// @dev Revert if _sellPrice is zero with "Invalid _sellPrice"
    /// @dev Revert if _requiredExperience is less than 100 with "Invalid _requiredExperience"
    /// @dev The ´name´ must be set to "Hero name"
    /// @dev The ´onSale´ must be set to true
    /// @param _attackPoints The attack points of the new hero
    /// @param _armorPoints The armor points of the new hero
    /// @param _weapon The weapons equiped of the new hero. Up to three weapons.
    /// @param _sellPrice The price in ethers of the new hero
    /// @param _requiredExperience The required experience to buy the new hero
    function mintHero(
        uint256 _attackPoints,
        uint256 _armorPoints,
        IWeapon[3] memory _weapon,
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external;
}

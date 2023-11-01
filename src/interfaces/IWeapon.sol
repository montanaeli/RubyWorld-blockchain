//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC721.sol";

interface IWeapon is IERC721 {
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
        uint256 characterID;
        uint256 attackPoints;
        uint256 armorPonits;
        uint256 sellPrice;
        uint256 requiredExperience;
        string name;
        bool onSale;
    }

    /// @dev Returns the metadata of the weapon in the indicated index
    function metadataOf(
        uint256 _tokenId
    ) external view returns (Metadata memory _metadata);

    /// @dev Returns the Character contract address
    function characterContract()
        external
        view
        returns (address _characterContract);

    /// @notice Mint a especial edition weapon NFT with special attributes
    /// @dev Throw if _attackPoints is less than 150 with "Invalid _attackPoints"
    /// @dev Throw if _armorPoints is less than 100 with "Invalid _armorPoints"
    /// @dev Throw if _sellPrice is zero with "Invalid _sellPrice"
    /// @dev Throw if _requiredExperience is less than 10 with "Invalid _requiredExperience"
    /// @dev The ´name´ must be set to "Lengendary weapon name"
    /// @dev The ´onSale´ must be set to true
    /// @param _attackPoints The attack points of the new weapon
    /// @param _armorPoints The armor points of the new weapon
    /// @param _sellPrice The price in ethers of the new weapon
    /// @param _requiredExperience The required experience to buy the new weapon
    function mintLegendaryWeapon(
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external;

    /// @notice Add a weapon to a character equipment
    /// @dev Throw if ´_weaponId´ does not exist with "Invalid _weaponId"
    /// @dev Throw if ´_characterId´ does not exist with "Invalid _characterId"
    /// @dev Throw if the weapon is already equipped to the character with "Weapon already equipped"
    /// @dev Throw if the character has already three weapons equipped with "Weapon slots are full"
    /// @dev Increase the attackPoints of the character in weapon attackPoints
    /// @dev Increase the armorPoints of the character in weapon armorPoints
    /// @dev Increase the character sellPrice in weapon sellPrice
    /// @dev Increase the character requiredExperience in weapon requiredExperience
    /// @param _weaponId The tokenId of the weapon to add
    /// @param _characterId The tokenId of the character to add the weapon
    function addWeaponToCharacter(
        uint256 _weaponId,
        uint256 _characterId
    ) external;

    /// @notice Remove a weapon to a character equipment
    /// @dev Throw if ´_weaponId´ does not exist with "Invalid _weaponId"
    /// @dev Throw if ´_characterId´ does not exist with "Invalid _characterId"
    /// @dev Throw if the weapon is not equipped to the character with "Weapon not equipped"
    /// @dev Decrease the attackPoints of the character in weapon attackPoints
    /// @dev Decrease the armorPoints of the character in weapon armorPoints
    /// @dev Decrease the character sellPrice in weapon sellPrice
    /// @dev Decrease the character requiredExperience in weapon requiredExperience
    /// @param _weaponId The tokenId of the weapon to add
    /// @param _characterId The tokenId of the character to add the weapon
    function removeWeaponFromCharacter(
        uint256 _weaponId,
        uint256 _characterId
    ) external;
}

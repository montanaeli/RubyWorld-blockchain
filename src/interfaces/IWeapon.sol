//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC721.sol";

/// @dev NFT interface
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

    /// @notice Mint a new Weapon NFT
    /// @dev Throw if the name is empty with "Invalid _name"
    /// @dev Throw if sender don't have enough Rubies to cover the price of the token to mint. Message: "Insufficient balance"
    /// @dev Throw if the contract don't have enough allowance to cover the price of the token to mint. Message: "Insufficient allowance"
    /// @dev Each minted weapon will start with 30 attackPoints and 5 armorPoints.
    /// @dev Set sellPrice to mintPrice, requiredExperience to 10 and onSale to false.
    /// @dev When mint is complete, this function checks if `_to` is a smart contract (code size > 0),
    /// if so, it calls `onERC721Received` on `_to` and throws if the return value is not
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    /// @param _name The name of the new weapon NFT
    function safeMint(string memory _name) external;

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

    /// @notice Return the sell metadata for a tokenId
    /// @dev Throw if the tokenId does not exist with "Invalid tokenId"
    /// @param _tokenId The tokenId of the weapon which information is requested
    /// @return _onSale True if the weapon is on sale. False otherwise.
    /// @return _price The price in ethers of the weapon
    /// @return _requiredExperience The required experience of the futur owner to buy the weapon
    function getSellInformation(
        uint256 _tokenId
    )
        external
        view
        returns (bool _onSale, uint256 _price, uint256 _requiredExperience);

    /// @notice Transfer the ownership of a weapon from owner address to sender address
    /// @dev The sender must pay the corresponding sellPrice in Rubies, otherwise Throw with "Not enough Rubies"
    /// @dev Throw if the tokenId does not exist with "Invalid tokenId"
    /// @dev Throw if the weapon is not on sale with "weapon not on sale"
    /// @dev Throw if the sender does not have enough experience to buy the weapon with "Insufficient experience"
    /// @dev Throw if sender don't have enough Rubies to cover the price of the token to buy. Message: "Insufficient balance"
    /// @dev Throw if the contract don't have enough allowance to cover the price of the token to buy. Message: "Insufficient allowance"
    /// @dev If the weapon is equipped to a character, it will be unequipped and then transferred to the new owner.
    /// @dev Set the name of the weapon to _newName
    /// @param _tokenId The tokenId of the weapon to buy
    /// @param _newName The new name of the weapon
    function buy(uint256 _tokenId, string memory _newName) external;

    /// @notice Set a weapon's onSale property to true to allow the sell of the weapon. To false otherwise.
    /// @dev Throw if the tokenId does not exist with "Invalid tokenId"
    function setOnSale(uint256 _tokenId, bool _onSale) external;

    /// @dev Set the mintage price
    function setMintPrice(uint256 _mintPrice) external;

    /// @dev Transfer to the OwnerContract the total balance in ethers that the contract has accumulated as fees.
    /// @dev This method must be able to be called only by ownersContract, otherwise it will Throw with the message "Not owners contract".
    /// @dev In the event that the contract does not have a balance, Throw with the message "zero balance".
    function collectFee() external;

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

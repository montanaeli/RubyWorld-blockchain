//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/ERC721.sol";
import "src/interfaces/IWeapon.sol";
import "src/interfaces/ICharacter.sol";
import "src/interfaces/IOwnersContract.sol";

/// @dev This contract must implement the IWeapon interface
contract Weapon is ERC721, IWeapon {
    address public characterContract;
    mapping(uint256 => Metadata) public metadata;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        address _ownerContract,
        address _characterContract
    ) ERC721(_name, _symbol, _tokenURI, _ownerContract) {
        characterContract = _characterContract;
    }

    function metadataOf(
        uint256 _tokenId
    ) external view returns (Metadata memory _metadata) {
        return metadata[_tokenId];
    }

    function safeMint(string memory _name) external {
        require(bytes(_name).length > 0, "Invalid name");
        // TODO: Check if the user has enough RUBIE tokens to mint a new character
        // TODO: CHeck if the user has enough allowance to mint this
        Metadata memory newWeapon = Metadata({
            characterID: 0, // TODO: This value must be the id of the character that is minting the new character
            attackPoints: 30,
            armorPonits: 5,
            sellPrice: mintPrice,
            requiredExperience: 10,
            name: _name,
            onSale: false
        });
        totalSupply++;
        balanceOf[msg.sender]++;
        ownerOf[totalSupply] = msg.sender;
        metadata[totalSupply] = newWeapon;
        // TODO:When mint is complete, this function checks if `_to` is a smart contract (code size > 0), if so, it calls `onERC721Received` on `_to` and throws if the return value is not `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    }

    function mintLegendaryWeapon(
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external {
        require(_attackPoints >= 150, "Invalid _attackPoints");
        require(_armorPoints >= 100, "Invalid _armorPoints");
        require(_sellPrice >= 0, "Invalid _sellPrice");
        require(_requiredExperience >= 10, "Invalid _requiredExperience");
        Metadata memory newLegendaryWeapon = Metadata({
            characterID: 0, // TODO: This value must be the id of the character that is minting the new character
            attackPoints: 30,
            armorPonits: 5,
            sellPrice: mintPrice,
            requiredExperience: 10,
            name: "Lengendary weapon name",
            onSale: true
        });
        totalSupply++;
        balanceOf[msg.sender]++;
        ownerOf[totalSupply] = msg.sender;
        metadata[totalSupply] = newLegendaryWeapon;
    }

    function getSellInformation(
        uint256 _tokenId
    )
        external
        view
        returns (bool _onSale, uint256 _price, uint256 _requiredExperience)
    {
        Metadata memory weaponMetadata = metadata[_tokenId];
        return (
            weaponMetadata.onSale,
            weaponMetadata.sellPrice,
            weaponMetadata.requiredExperience
        );
    }

    function buy(uint256 _tokenId, string memory _newName) external {
        // TODO: Check if the sender has paid enough rubies
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(metadata[_tokenId].onSale, "weapon not on sale");
        // TODO: Check if the sender has enough experience
        // TODO: Check if the sender has enough rubies to cover the price of the token
        // TODO: Check if the user has enough balance to buy the token
        // TODO: Check if the weapon is equiped to a character, and if so, unequip it and then transferred to the new owner.
        ownerOf[_tokenId] = msg.sender;
        metadata[_tokenId].name = _newName;
    }

    function setOnSale(uint256 _tokenId, bool _onSale) external {
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(msg.sender == ownerOf[_tokenId], "Not authorized");
        metadata[_tokenId].onSale = _onSale;
    }

    function collectFee() external {
        // To be implemented
    }

    function addWeaponToCharacter(
        uint256 _weaponId,
        uint256 _characterId
    ) external {
        /// @dev Check if the weapon exists
        /// @dev Check if the character exists
        /// @dev Check if the weapon is already equiped
        /// @dev Check if the character already has 3 weapon equiped
        /// @dev Increase the attackPoints of the character in weapon attackPoints
        /// @dev Increase the armorPoints of the character in weapon armorPoints
        /// @dev Increase the character sellPrice in weapon sellPrice
        /// @dev Increase the character requiredExperience in weapon requiredExperience
    }

    function removeWeaponFromCharacter(
        uint256 _weaponId,
        uint256 _characterId
    ) external {
        // To be implemented
    }
}

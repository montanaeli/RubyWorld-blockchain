//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC721.sol";
import "src/interfaces/ICharacter.sol";
import "src/interfaces/IOwnersContract.sol";

/// @dev This contract must implement the ICharacter interface
contract Character is ICharacter, ERC721 {
    uint256 public defaultRequiredExpirience;

    mapping(uint256 => Metadata) public metadata;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        address _ownersContract
    ) ERC721(_name, _symbol, _tokenURI, _ownersContract) {
        defaultRequiredExpirience = 100;
    }

    function metadataOf(
        uint256 _tokenId
    ) external view returns (Metadata memory _metadata) {
        return metadata[_tokenId];
    }

    function weapon(
        uint256 _weaponIndex
    ) external view returns (IWeapon _weapon) {
        // To be Implemented
        // Don't we need the tokenId of the character here?
        // Or should we know the tokenId of the character from the weaponIndex?
    }

    function safeMint(string memory _name) external payable {
        require(bytes(_name).length > 0, "Invalid name");
        require(msg.value >= mintPrice, "Not enough ETH");
        uint256[3] memory defaultEmptyWeapons;
        Metadata memory newCharacterMetadata = Metadata({
            name: _name,
            attackPoints: 100,
            armorPoints: 50,
            weapon: defaultEmptyWeapons,
            sellPrice: mintPrice,
            requiredExperience: defaultRequiredExpirience,
            onSale: false
        });
        totalSupply++;
        balanceOf[msg.sender]++;
        ownerOf[totalSupply] = msg.sender;
        metadata[totalSupply] = newCharacterMetadata;
        // TODO: With each new minted character, the owner account will recieve 1000 RUBIE tokens
        // TODO:When mint is complete, this function checks if `_to` is a smart contract (code size > 0), if so, it calls `onERC721Received` on `_to` and throws if the return value is not `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    }

    function mintHero(
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256[3] memory _weapon,
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external {
        require(_attackPoints > 100, "Invalid _attackPoints");
        require(_armorPoints > 50, "Invalid _armorPoints");
        require(_sellPrice > 0, "Invalid _sellPrice");
        require(_requiredExperience > 100, "Invalid _requiredExperience");
        require(msg.sender == owner, "Not the owner");
        // Check if the msg.value has founds?
        Metadata memory newCharacterMetadata = Metadata({
            name: "Hero name",
            attackPoints: _attackPoints,
            armorPoints: _armorPoints,
            weapon: _weapon,
            sellPrice: _sellPrice,
            requiredExperience: _requiredExperience,
            onSale: true
        });
        totalSupply++;
        balanceOf[msg.sender]++;
        ownerOf[totalSupply] = msg.sender;
        metadata[totalSupply] = newCharacterMetadata;
    }

    function getSellinformation(
        uint256 _tokenId
    )
        external
        view
        returns (bool _onSale, uint256 _price, uint256 _requiredExperience)
    {
        Metadata memory characterMetadata = metadata[_tokenId];
        return (
            characterMetadata.onSale,
            characterMetadata.sellPrice,
            characterMetadata.requiredExperience
        );
    }

    function setMintingPrice(uint256 _mintPrice) external {
        mintPrice = _mintPrice;
    }

    function buy(uint256 _tokenId, string memory _newName) external payable {
        require(msg.value >= metadata[_tokenId].sellPrice, "Not enough ETH");
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(metadata[_tokenId].onSale, "Character not on sale");
        // TODO: Check if the sender has enough experience
        // TODO: Transfer de weapons
        ownerOf[_tokenId] = msg.sender;
        metadata[_tokenId].name = _newName;
    }

    function setOnSale(uint256 _tokenId, bool _onSale) external {
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(msg.sender == ownerOf[_tokenId], "Not the owner");
        metadata[_tokenId].onSale = _onSale;
    }

    function collectFee() external {
        require(msg.sender == owner, "Not the owner");
        // To be implemented
    }
}

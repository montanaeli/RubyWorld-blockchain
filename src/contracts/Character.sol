//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC721.sol";
import "src/interfaces/ICharacter.sol";
import "src/interfaces/IOwnersContract.sol";
import "src/interfaces/IRubie.sol";
import "src/interfaces/IExperience.sol";
import "src/interfaces/IER721TokenReceiver.sol";
import "src/contracts/OwnersContract.sol";
import "src/contracts/Rubie.sol";

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

    function getTokensOf(
        address _owner
    ) external view returns (uint256[] memory _tokens) {
        return tokensOf[_owner];
    }

    function upgradeCharacter(
        uint256 _tokenId,
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256 _sellPrice
    ) external {
        metadata[_tokenId].attackPoints = _attackPoints;
        metadata[_tokenId].armorPoints = _armorPoints;
        metadata[_tokenId].sellPrice = _sellPrice;
    }

    function weapon(
        uint256 _weaponIndex
    ) external view returns (uint256 _weapon) {
        return metadata[_weaponIndex].weapon[_weaponIndex];
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
        address rubieContractAddress = OwnersContract(ownersContract).addressOf(
            "Rubie"
        );
        balanceOf[ownersContract] += msg.value;
        Rubie(rubieContractAddress).transfer(msg.sender, 1000);
        isERC721_TokenReceiver(msg.sender, totalSupply);
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
        require(
            OwnersContract(ownersContract).owners(msg.sender),
            "Not the owner"
        );
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

    function buy(uint256 _tokenId, string memory _newName) external payable {
        require(msg.value >= metadata[_tokenId].sellPrice, "Not enough ETH");
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(metadata[_tokenId].onSale, "Character not on sale");
        address experienceContractAddress = OwnersContract(ownersContract)
            .addressOf("Experience");
        require(
            IExperience(experienceContractAddress).balanceOf(msg.sender) >=
                metadata[_tokenId].requiredExperience,
            "Insufficient experience"
        );
        /// Transfer the weapons
        for (uint256 i = 0; i < metadata[_tokenId].weapon.length; i++) {
            if (metadata[_tokenId].weapon[i] != 0) {
                IExperience(experienceContractAddress).transferFrom(
                    msg.sender,
                    ownerOf[_tokenId],
                    metadata[_tokenId].weapon[i]
                );
            }
        }
        balanceOf[ownersContract] += msg.value;
        ownerOf[_tokenId] = msg.sender;
        metadata[_tokenId].name = _newName;
    }

    function setOnSale(uint256 _tokenId, bool _onSale) external {
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(msg.sender == ownerOf[_tokenId], "Not the owner");
        metadata[_tokenId].onSale = _onSale;
    }

    /// FUNCIONES PRIVADAS
    function _isSmartContract(address _address) private view returns (bool) {
        return (_address.code.length > 0);
    }

    function isERC721_TokenReceiver(
        address _address,
        uint256 _tokenId
    ) private {
        if (_isSmartContract(_address)) {
            bytes4 ERC721_TokenReceiver_Hash = 0x150b7a02;
            bytes memory _data;
            bytes4 ERC721Received_result = IERC721TokenReceiver(_address)
                .onERC721Received(address(this), msg.sender, _tokenId, _data);
            if (ERC721Received_result != ERC721_TokenReceiver_Hash) {
                revert("No ERC721Receiver");
            }
        }
    }
}

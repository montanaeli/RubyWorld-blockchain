//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC721.sol";
import "src/interfaces/ICharacter.sol";
import "src/interfaces/IOwnersContract.sol";
import "src/interfaces/IRubie.sol";
import "src/interfaces/IWeapon.sol";
import "src/interfaces/IExperience.sol";

/// @dev This contract must implement the ICharacter interface
contract Character is ICharacter, ERC721 {
    mapping(uint256 => Metadata) public metadata;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        address _ownersContract
    ) ERC721(_name, _symbol, _tokenURI, _ownersContract, 1) {}

    function metadataOf(
        uint256 _tokenId
    )
        external
        view
        isValidTokenId(_tokenId)
        returns (Metadata memory _metadata)
    {
        return metadata[_tokenId];
    }

    function getCharacterTokenId(
        address _owner
    ) external view isValidAddress(_owner) returns (uint256 _tokens) {
        require(tokensOf[_owner].length > 0, "No character found");
        return tokensOf[_owner][0];
    }

    function setMetadataFromExperience(
        uint256 _tokenId,
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256 _sellPrice
    ) external isValidTokenId(_tokenId) {
        require(
            msg.sender ==
                IOwnersContract(ownersContract).addressOf("Experience"),
            "Not experience contract"
        );
        metadata[_tokenId].attackPoints = _attackPoints;
        metadata[_tokenId].armorPoints = _armorPoints;
        metadata[_tokenId].sellPrice = _sellPrice;
    }

    function weapon(
        uint256 _weaponIndex
    ) external view isValidTokenId(_weaponIndex) returns (uint256 _weapon) {
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
            requiredExperience: 100,
            onSale: false
        });
        totalSupply++;
        balanceOf[msg.sender]++;
        ownerOf[totalSupply] = msg.sender;
        tokensOf[msg.sender].push(totalSupply);
        metadata[totalSupply] = newCharacterMetadata;
        balanceOf[ownersContract] += msg.value;
        address rubieContractAddress = IOwnersContract(ownersContract)
            .addressOf("Rubie");
        IRubie(rubieContractAddress).mintFromCharacter(1000);
        IRubie(rubieContractAddress).transfer(msg.sender, 1000);
        this.isERC721TokenReceiver(msg.sender, totalSupply);
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
            IOwnersContract(ownersContract).owners(msg.sender),
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
        isValidTokenId(_tokenId)
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
        require(_tokenId > 0 && _tokenId <= totalSupply, "Invalid tokenId");
        require(metadata[_tokenId].onSale, "Character not on sale");
        address experienceContractAddress = IOwnersContract(ownersContract)
            .addressOf("Experience");

        require(
            IExperience(experienceContractAddress).balanceOf(msg.sender) >=
                metadata[_tokenId].requiredExperience,
            "Insufficient experience"
        );

        /// Transfer the weapons
        for (uint256 i = 0; i < metadata[_tokenId].weapon.length; i++) {
            if (metadata[_tokenId].weapon[i] != 0) {
                IWeapon(experienceContractAddress).safeTransferFrom(
                    msg.sender,
                    ownerOf[_tokenId],
                    metadata[_tokenId].weapon[i]
                );
            }
        }
        // Tranfiero el dinero y asigno al nuevo propietario
        address _oldOwner = ownerOf[_tokenId];

        payable(_oldOwner).transfer(metadata[_tokenId].sellPrice);
        if (msg.value > metadata[_tokenId].sellPrice) {
            // para no perder el cambio
            payable(msg.sender).transfer(
                msg.value - metadata[_tokenId].sellPrice
            );
        }

        metadata[_tokenId].name = _newName;
        this.safeTransferFrom(_oldOwner, msg.sender, _tokenId);

        // recolecto los ethers que gana el owner de acuerdo a su porcentaje de ganancia
        uint256 tokenSellFeePercentage = IOwnersContract(_oldOwner)
            .tokenSellFeePercentage();
        totalFees += metadata[_tokenId].sellPrice * tokenSellFeePercentage;
    }

    function setMintingPrice(uint256 _mintPrice) external {
        this.setMintPrice(_mintPrice);
    }

    function setOnSale(
        uint256 _tokenId,
        bool _onSale
    ) external isValidTokenId(_tokenId) {
        require(msg.sender == ownerOf[_tokenId], "Not authorized");
        metadata[_tokenId].onSale = _onSale;
    }

    function setMetadataFromWeapon(
        uint256 _tokenId,
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external isValidTokenId(_tokenId) {
        require(
            msg.sender == IOwnersContract(ownersContract).addressOf("Weapon"),
            "Not weapon contract"
        );
        metadata[_tokenId].attackPoints = _attackPoints;
        metadata[_tokenId].armorPoints = _armorPoints;
        metadata[_tokenId].sellPrice = _sellPrice;
        metadata[_tokenId].requiredExperience = _requiredExperience;
    }
}

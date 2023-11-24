//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC721.sol";
import "src/interfaces/IWeapon.sol";
import "src/interfaces/ICharacter.sol";
import "src/interfaces/IOwnersContract.sol";
import "src/interfaces/IRubie.sol";
import "src/interfaces/IExperience.sol";

/// @dev This contract must implement the IWeapon interface
contract Weapon is ERC721, IWeapon {
    address public characterContract;

    mapping(uint256 => Metadata) public metadata;

    modifier isContractOwner(address _address) {
        require(
            IOwnersContract(ownersContract).owners(_address),
            "Not the owner"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        address _ownerContract,
        address _characterContract
    ) ERC721(_name, _symbol, _tokenURI, _ownerContract, 0) {
        characterContract = _characterContract;
    }

    function metadataOf(
        uint256 _tokenId
    ) external view returns (Metadata memory _metadata) {
        return metadata[_tokenId];
    }

    function safeMint(string memory _name) external {
        require(bytes(_name).length > 0, "Invalid name");
        address rubiesAddressContract = IOwnersContract(ownersContract)
            .addressOf("Rubie");
        require(
            IRubie(rubiesAddressContract).balanceOf(msg.sender) >= mintPrice,
            "Insufficient balance"
        );
        require(
            IRubie(rubiesAddressContract).allowance(
                msg.sender,
                address(this)
            ) >= mintPrice,
            "Insufficient allowance"
        );
        Metadata memory newWeapon = Metadata({
            characterID: 0,
            attackPoints: 30,
            armorPoints: 5,
            sellPrice: mintPrice,
            requiredExperience: 10,
            name: _name,
            onSale: false
        });
        totalSupply++;
        balanceOf[msg.sender]++;
        ownerOf[totalSupply] = msg.sender;
        metadata[totalSupply] = newWeapon;
        this.isERC721TokenReceiver(msg.sender, totalSupply);
    }

    function mintLegendaryWeapon(
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external isContractOwner(msg.sender) {
        require(_attackPoints >= 150, "Invalid _attackPoints");
        require(_armorPoints >= 100, "Invalid _armorPoints");
        require(_sellPrice >= 0, "Invalid _sellPrice");
        require(_requiredExperience >= 10, "Invalid _requiredExperience");
        Metadata memory newLegendaryWeapon = Metadata({
            characterID: 0,
            attackPoints: 30,
            armorPoints: 5,
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

    function buy(uint256 _tokenId, string memory _newName) external payable {
        require(msg.value >= metadata[_tokenId].sellPrice, "Not enough Rubies");
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(metadata[_tokenId].onSale, "weapon not on sale");
        address experienceContractAddress = IOwnersContract(ownersContract)
            .addressOf("Experience");
        require(
            IExperience(experienceContractAddress).balanceOf(msg.sender) >=
                metadata[_tokenId].requiredExperience,
            "Insufficient experience"
        );
        address rubieContractAddress = IOwnersContract(ownersContract)
            .addressOf("Rubie");
        require(
            IRubie(rubieContractAddress).balanceOf(msg.sender) >=
                metadata[_tokenId].sellPrice,
            "Insufficient Rubies"
        );
        require(
            IRubie(rubieContractAddress).allowance(msg.sender, address(this)) >=
                mintPrice,
            "Insufficient allowance"
        );
        if (metadata[_tokenId].characterID != 0) {
            ICharacter(characterContract)
                .metadataOf(metadata[_tokenId].characterID)
                .attackPoints -= metadata[_tokenId].attackPoints;
            ICharacter(characterContract)
                .metadataOf(metadata[_tokenId].characterID)
                .armorPoints -= metadata[_tokenId].armorPoints;
            ICharacter(characterContract)
                .metadataOf(metadata[_tokenId].characterID)
                .sellPrice -= metadata[_tokenId].sellPrice;
            ICharacter(characterContract)
                .metadataOf(metadata[_tokenId].characterID)
                .requiredExperience -= metadata[_tokenId].requiredExperience;
        }

        address _oldOwner = ownerOf[_tokenId];
        payable(_oldOwner).transfer(metadata[_tokenId].sellPrice);
        if (msg.value > metadata[_tokenId].sellPrice) {
            // para no perder el cambio
            payable(msg.sender).transfer(
                msg.value - metadata[_tokenId].sellPrice
            );
        }
        ownerOf[_tokenId] = msg.sender;
        metadata[_tokenId].name = _newName;
        this.safeTransfer(msg.sender, _tokenId);

        // recolecto los ethers que gana el owner de a cuerdo a su porcentaje de ganancia
        uint256 tokenSellFeePercentage = OwnersContract(_oldOwner)
            .tokenSellFeePercentage();
        totalFees += metadata[_tokenId].sellPrice * tokenSellFeePercentage;
    }

    function setOnSale(uint256 _tokenId, bool _onSale) external {
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(msg.sender == ownerOf[_tokenId], "Not authorized");
        metadata[_tokenId].onSale = _onSale;
    }

    function addWeaponToCharacter(
        uint256 _weaponId,
        uint256 _characterId
    ) external {
        require(_weaponId < totalSupply && _weaponId > 0, "Invalid _weaponId");
        require(
            _characterId < ICharacter(characterContract).totalSupply() &&
                _characterId > 0,
            "Invalid _characterId"
        );
        require(
            metadata[_weaponId].characterID != _characterId,
            "Weapon already equipped"
        );
        require(
            ICharacter(characterContract).metadataOf(_characterId).weapon[0] ==
                0 ||
                ICharacter(characterContract).metadataOf(_characterId).weapon[
                    1
                ] ==
                0 ||
                ICharacter(characterContract).metadataOf(_characterId).weapon[
                    2
                ] ==
                0,
            "Weapon slots are full"
        );
        ICharacter(characterContract)
            .metadataOf(_characterId)
            .attackPoints += metadata[_weaponId].attackPoints;
        ICharacter(characterContract)
            .metadataOf(_characterId)
            .armorPoints += metadata[_weaponId].armorPoints;
        ICharacter(characterContract)
            .metadataOf(_characterId)
            .sellPrice += metadata[_weaponId].sellPrice;
        ICharacter(characterContract)
            .metadataOf(_characterId)
            .requiredExperience += metadata[_weaponId].requiredExperience;
        metadata[_weaponId].characterID = _characterId;
    }

    function removeWeaponFromCharacter(
        uint256 _weaponId,
        uint256 _characterId
    ) external {
        require(_weaponId < totalSupply && _weaponId > 0, "Invalid _weaponId");
        require(
            _characterId < ICharacter(characterContract).totalSupply() &&
                _characterId > 0,
            "Invalid _characterId"
        );
        require(
            metadata[_weaponId].characterID == _characterId,
            "Weapon not equipped"
        );
        require(
            ICharacter(characterContract).metadataOf(_characterId).weapon[0] ==
                0 ||
                ICharacter(characterContract).metadataOf(_characterId).weapon[
                    1
                ] ==
                0 ||
                ICharacter(characterContract).metadataOf(_characterId).weapon[
                    2
                ] ==
                0,
            "Weapon slots are full"
        );
        ICharacter(characterContract)
            .metadataOf(_characterId)
            .attackPoints -= metadata[_weaponId].attackPoints;
        ICharacter(characterContract)
            .metadataOf(_characterId)
            .armorPoints -= metadata[_weaponId].armorPoints;
        ICharacter(characterContract)
            .metadataOf(_characterId)
            .sellPrice -= metadata[_weaponId].sellPrice;
        ICharacter(characterContract)
            .metadataOf(_characterId)
            .requiredExperience -= metadata[_weaponId].requiredExperience;
        metadata[_weaponId].characterID = 0;
    }
}

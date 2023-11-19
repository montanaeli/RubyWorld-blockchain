//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC721.sol";
import "src/interfaces/IWeapon.sol";
import "src/interfaces/ICharacter.sol";
import "src/interfaces/IOwnersContract.sol";
import "src/interfaces/IRubie.sol";
import "src/interfaces/IExperience.sol";
import "./OwnersContract.sol";
import "./Rubie.sol";

/// @dev This contract must implement the IWeapon interface
contract Weapon is ERC721, IWeapon {
    address public characterContract;
    mapping(uint256 => Metadata) public metadata;

    modifier isContractOwner(address _address) {
        require(
            OwnersContract(ownersContract).owners(_address),
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
    ) ERC721(_name, _symbol, _tokenURI, _ownerContract, 3) {
        require(bytes(_name).length > 0, "Invalid name");
        require(bytes(_symbol).length == 3, "Invalid symbol");
        require(
            ownersContract != address(0),
            "Invalid ownsers contract address"
        );
        require(
            _characterContract != address(0),
            "Invalid character contract address"
        );
        characterContract = _characterContract;
    }

    function metadataOf(
        uint256 _tokenId
    ) external view returns (Metadata memory _metadata) {
        return metadata[_tokenId];
    }

    function safeMint(string memory _name) external {
        require(bytes(_name).length > 0, "Invalid name");
        address rubiesAddressContract = OwnersContract(ownersContract)
            .addressOf("Rubie");
        require(
            Rubie(rubiesAddressContract).balanceOf(msg.sender) >= mintPrice,
            "Insufficient balance"
        );
        require(
            Rubie(rubiesAddressContract).allowance(msg.sender, address(this)) >=
                mintPrice,
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
        //this.isERC721TokenReceiver(msg.sender, totalSupply);
    }

    function mintLegendaryWeapon(
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external {
        require(_attackPoints >= 150, "Invalid _attackPoints");
        require(_armorPoints >= 100, "Invalid _armorPoints");
        require(_sellPrice > 0, "Invalid _sellPrice");
        require(_requiredExperience >= 10, "Invalid _requiredExperience");
        require(
            OwnersContract(ownersContract).owners(msg.sender),
            "Not the owner"
        );
        Metadata memory newLegendaryWeapon = Metadata({
            characterID: 0,
            attackPoints: _attackPoints,
            armorPoints: _armorPoints,
            sellPrice: _sellPrice,
            requiredExperience: _requiredExperience,
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
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
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
        address experienceContractAddress = OwnersContract(ownersContract)
            .addressOf("Experience");
        require(
            IExperience(experienceContractAddress).balanceOf(msg.sender) >=
                metadata[_tokenId].requiredExperience,
            "Insufficient experience"
        );
        address rubieContractAddress = OwnersContract(ownersContract).addressOf(
            "Rubie"
        );
        require(
            IRubie(rubieContractAddress).balanceOf(msg.sender) >=
                metadata[_tokenId].sellPrice,
            "Insufficient Rubies"
        );
        require(
            Rubie(rubieContractAddress).allowance(msg.sender, address(this)) >=
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
        ownerOf[_tokenId] = msg.sender;
        metadata[_tokenId].name = _newName;
        this.safeTransfer(msg.sender, _tokenId);
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

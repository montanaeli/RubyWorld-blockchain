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

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        address _ownerContract,
        address _characterContract
    ) ERC721(_name, _symbol, _tokenURI, _ownerContract, 3) {
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
        addTokenToAddress(msg.sender, totalSupply);
        this.isERC721TokenReceiver(msg.sender, totalSupply);
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
            IOwnersContract(ownersContract).owners(msg.sender),
            "Not the owner"
        );
        uint256 rubiePrice = IRubie(
            IOwnersContract(ownersContract).addressOf("Rubie")
        ).price();

        Metadata memory newLegendaryWeapon = Metadata({
            characterID: 0,
            attackPoints: _attackPoints,
            armorPoints: _armorPoints,
            sellPrice: _sellPrice / rubiePrice,
            requiredExperience: _requiredExperience,
            name: "Lengendary weapon name",
            onSale: true
        });
        totalSupply++;
        balanceOf[msg.sender]++;
        ownerOf[totalSupply] = msg.sender;
        metadata[totalSupply] = newLegendaryWeapon;
        addTokenToAddress(msg.sender, totalSupply);
    }

    function getSellInformation(
        uint256 _tokenId
    )
        external
        view
        returns (bool _onSale, uint256 _price, uint256 _requiredExperience)
    {
        require(_tokenId <= totalSupply && _tokenId > 0, "Invalid tokenId");
        Metadata memory weaponMetadata = metadata[_tokenId];
        return (
            weaponMetadata.onSale,
            weaponMetadata.sellPrice,
            weaponMetadata.requiredExperience
        );
    }

    function buy(uint256 _tokenId, string memory _newName) external payable {
        address rubieContractAddress = IOwnersContract(ownersContract)
            .addressOf("Rubie");
        require(
            IRubie(rubieContractAddress).balanceOf(msg.sender) >=
                metadata[_tokenId].sellPrice,
            "Not enough Rubies"
        );
        require(_tokenId <= totalSupply && _tokenId > 0, "Invalid tokenId");
        require(metadata[_tokenId].onSale, "weapon not on sale");
        address experienceContractAddress = IOwnersContract(ownersContract)
            .addressOf("Experience");
        require(
            IExperience(experienceContractAddress).balanceOf(msg.sender) >=
                metadata[_tokenId].requiredExperience,
            "Insufficient experience"
        );
        require(
            IRubie(rubieContractAddress).allowance(msg.sender, address(this)) >=
                mintPrice,
            "Insufficient allowance"
        );

        // if (metadata[_tokenId].characterID != 0) {
        //     // Look for an empty index of the weapon array and if not revert with not enough slots
        //     uint256 weaponIndex = 0;
        //     while (
        //         ICharacter(characterContract)
        //             .metadataOf(metadata[_tokenId].characterID)
        //             .weapon[weaponIndex] != 0
        //     ) {
        //         weaponIndex++;
        //     }
        //     require(
        //         weaponIndex > 0 && weaponIndex < 4,
        //         "Weapon slots are full"
        //     );

        //     ICharacter(characterContract).setMetadataFromWeapon(
        //         metadata[_tokenId].characterID,
        //         ICharacter(characterContract)
        //             .metadataOf(_tokenId)
        //             .attackPoints - metadata[_tokenId].attackPoints,
        //         ICharacter(characterContract).metadataOf(_tokenId).armorPoints -
        //             metadata[_tokenId].armorPoints,
        //         ICharacter(characterContract).metadataOf(_tokenId).sellPrice -
        //             metadata[_tokenId].sellPrice,
        //         ICharacter(characterContract)
        //             .metadataOf(_tokenId)
        //             .requiredExperience - metadata[_tokenId].requiredExperience,
        //         weaponIndex,
        //         _tokenId
        //     );
        // }

        // TODO: check if the weapon is equiped to another character and if so unequip it and transfer it to the new owner

        address oldOwner = ownerOf[_tokenId];
        // The Rubies that the sender paid must be transferred to the owner of the token
        IRubie(rubieContractAddress).transferFrom(
            msg.sender,
            oldOwner,
            metadata[_tokenId].sellPrice
        );

        metadata[_tokenId].name = _newName;
        this.safeTransferFrom(oldOwner, msg.sender, _tokenId);

        // recolecto los ethers que gana el owner de a cuerdo a su porcentaje de ganancia
        uint256 tokenSellFeePercentage = IOwnersContract(ownersContract)
            .tokenSellFeePercentage();
        balanceOf[ownersContract] +=
            metadata[_tokenId].sellPrice *
            tokenSellFeePercentage;
    }

    function setOnSale(uint256 _tokenId, bool _onSale) external {
        require(_tokenId <= totalSupply && _tokenId > 0, "Invalid tokenId");
        require(msg.sender == ownerOf[_tokenId], "Not authorized");
        metadata[_tokenId].onSale = _onSale;
    }

    function addWeaponToCharacter(
        uint256 _weaponId,
        uint256 _characterId
    ) external {
        require(_weaponId <= totalSupply && _weaponId > 0, "Invalid _weaponId");
        require(
            _characterId <= ICharacter(characterContract).totalSupply() &&
                _characterId > 0,
            "Invalid _characterId"
        );
        require(
            metadata[_weaponId].characterID != _characterId,
            "Weapon already equipped"
        );
        uint256 weaponSlot = 0;
        for (uint256 i = 0; i < 3; i++) {
            if (
                ICharacter(characterContract).metadataOf(_characterId).weapon[
                    i
                ] == 0
            ) {
                weaponSlot = i;
                break;
            }
        }
        require(weaponSlot >= 0 && weaponSlot < 3, "Weapon slots are full");
        require(
            allowance[_weaponId] == msg.sender ||
                ownerOf[_weaponId] == msg.sender,
            "Not authorized to operate the weapon"
        );
        require(
            ICharacter(characterContract).allowance(_characterId) ==
                msg.sender ||
                ICharacter(characterContract).ownerOf(_characterId) ==
                msg.sender,
            "Not authorized to operate the character"
        );
        require(
            ICharacter(characterContract).ownerOf(_characterId) == msg.sender &&
                ownerOf[_weaponId] == msg.sender,
            "Tokens from different owners"
        );

        ICharacter(characterContract).setMetadataFromWeapon(
            _characterId,
            ICharacter(characterContract).metadataOf(_weaponId).attackPoints +
                metadata[_weaponId].attackPoints,
            ICharacter(characterContract).metadataOf(_weaponId).armorPoints +
                metadata[_weaponId].armorPoints,
            ICharacter(characterContract).metadataOf(_weaponId).sellPrice +
                metadata[_weaponId].sellPrice,
            ICharacter(characterContract)
                .metadataOf(_weaponId)
                .requiredExperience + metadata[_weaponId].requiredExperience,
            weaponSlot,
            _weaponId
        );
        metadata[_weaponId].characterID = _characterId;
    }

    function removeWeaponFromCharacter(
        uint256 _weaponId,
        uint256 _characterId
    ) external {
        require(_weaponId < totalSupply && _weaponId > 0, "Invalid _weaponId");
        require(
            _characterId <= ICharacter(characterContract).totalSupply() &&
                _characterId > 0,
            "Invalid _characterId"
        );
        require(
            metadata[_weaponId].characterID == _characterId,
            "Weapon not equipped"
        );
        uint256 weaponSlot = 0;
        for (uint256 i = 0; i < 3; i++) {
            if (
                ICharacter(characterContract).metadataOf(_characterId).weapon[
                    i
                ] == 0
            ) {
                weaponSlot = i;
                break;
            }
        }
        require(weaponSlot > 0 && weaponSlot < 4, "Weapon slots are full");
        require(ownerOf[_weaponId] == msg.sender, "Not authorized");

        // Look for an empty index of the weapon array and if not revert with not enough slots
        // uint256 weaponSlot = 0;
        // while (
        //     ICharacter(characterContract).metadataOf(_characterId).weapon[
        //         weaponSlot
        //     ] != 0
        // ) {
        //     weaponSlot++;
        // }
        // require(weaponSlot > 0 && weaponSlot < 4, "Weapon slots are full");

        // for (uint256 i = 0; i < 3; i++) {
        //     if (
        //         ICharacter(characterContract).metadataOf(_characterId).weapon[
        //             i
        //         ] == _weaponId
        //     ) {
        //         revert("Weapon already equipped");
        //     }
        // }

        ICharacter(characterContract).setMetadataFromWeapon(
            _characterId,
            ICharacter(characterContract)
                .metadataOf(_characterId)
                .attackPoints - metadata[_weaponId].attackPoints,
            ICharacter(characterContract).metadataOf(_characterId).armorPoints -
                metadata[_weaponId].armorPoints,
            ICharacter(characterContract).metadataOf(_characterId).sellPrice -
                metadata[_weaponId].sellPrice,
            ICharacter(characterContract)
                .metadataOf(_characterId)
                .requiredExperience - metadata[_weaponId].requiredExperience,
            weaponSlot,
            _weaponId
        );
        metadata[_weaponId].characterID = 0;
    }
}

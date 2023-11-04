//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/ICharacter.sol";

// General Doubts of the implementation:
// * For 'operator' mapping, when exactly shoud I add an operator?
// * Para las Weapons, hay una array de tres integers, como lo vamos a mappear?
// * Para el mintHero, te pasan las intancias de Weapon ya? Como sabemos que int es para asc

/// @dev This contract must implement the ICharacter interface
contract Character is ICharacter {
    // Events
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _value
    );

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public mintPrice;

    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) public allowance;
    mapping(uint256 => Metadata) public metadataOf;
    mapping(address => mapping(address => bool)) public operator;
    mapping(uint256 => string) public tokenURI;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _mintPrice
    ) {
        name = _name;
        symbol = _symbol;
        mintPrice = _mintPrice;
    }

    function safeTransfer(address _to, uint256 _tokenId) external {
        // TODO: The part of the safe transfer
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(_to != address(0), "Invalid address");
        require(ownerOf[_tokenId] == msg.sender, "Not the owner");
        ownerOf[_tokenId] = _to;
        balanceOf[msg.sender]--;
        balanceOf[_to]++;
        allowance[_tokenId] = address(0);
        emit Transfer(msg.sender, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        // TODO: Remains to implement the penultimum DEV requirement
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(_to != address(0), "Invalid address");
        require(
            _from == msg.sender ||
                allowance[_tokenId] == msg.sender ||
                operator[ownerOf[_tokenId]][msg.sender],
            "Not the owner"
        );
        ownerOf[_tokenId] = _to;
        balanceOf[_from]--;
        balanceOf[_to]++;
        allowance[_tokenId] = address(0);
        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external {
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        address _tokenOwner = ownerOf[_tokenId];
        require(
            msg.sender == _tokenOwner ||
                allowance[_tokenId] == msg.sender ||
                operator[_tokenOwner][msg.sender]
        );
        allowance[_tokenId] = _approved;
    }

    function weapon(
        uint256 _weaponIndex
    ) external view returns (IWeapon _weapon) {
        // To be Implemented
        // Don't we need the tokenId of the character here?
        // Or should we know the tokenId of the character from the weaponIndex?
    }

    function safeMint(string memory _name) external {
        require(bytes(_name).length > 0, "Invalid name");
        // Check the rest of the conditions

        // Metadata memory newCharacterMetadata = Metadata({
        //     name: _name,
        //     attackPoints: 100,
        //     armorPoints: 50,
        //     weapon: new uint256[3],
        //     sellPrice: 0,
        //     requiredExperience: 0,
        //     onSale: false
        // });
        // totalSupply++;
        // balanceOf[msg.sender]++;
        // ownerOf[totalSupply] = msg.sender;
        // tokenURI[totalSupply] = _name;
    }

    function mintHero(
        uint256 _attackPoints,
        uint256 _armorPoints,
        IWeapon[3] memory _weapon,
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external {
        require(_attackPoints > 100, "Invalid _attackPoints");
        require(_armorPoints > 50, "Invalid _armorPoints");
        require(_sellPrice > 0, "Invalid _sellPrice");
        require(_requiredExperience > 100, "Invalid _requiredExperience");
        // Metadata memory newCharacterMetadata = Metadata({
        //     name: "Hero name",
        //     attackPoints: _attackPoints,
        //     armorPoints: _armorPoints,
        //     weapon: _weapon,
        //     sellPrice: _sellPrice,
        //     requiredExperience: _requiredExperience,
        //     onSale: true
        // });
        // totalSupply++;
        // balanceOf[msg.sender]++;
        // ownerOf[totalSupply] = msg.sender;
        // tokenURI[totalSupply] = "Hero name";
    }

    function getSellinformation(
        uint256 _tokenId
    )
        external
        view
        returns (bool _onSale, uint256 _price, uint256 _requiredExperience)
    {
        Metadata memory characterMetadata = metadataOf[_tokenId];
        return (
            characterMetadata.onSale,
            characterMetadata.sellPrice,
            characterMetadata.requiredExperience
        );
    }

    function buy(uint256 _tokenId, string memory _newName) external {
        // TODO: Check if the sender pays the corresponding sellPrice in ETH
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        require(metadataOf[_tokenId].onSale, "Character not on sale");
        // TODO: Check if the sender has enough experience
        // TODO: Transfer de weapons
        ownerOf[_tokenId] = msg.sender;
        metadataOf[_tokenId].name = _newName;
    }

    function setOnSale(uint256 _tokenId, bool _onSale) external {
        require(_tokenId < totalSupply && _tokenId > 0, "Invalid tokenId");
        metadataOf[_tokenId].onSale = _onSale;
    }

    function currentTokenID() external view returns (uint256 _currentTokenID) {
        return totalSupply;
    }

    function setMintingPrice(uint256 _mintPrice) external {
        mintPrice = _mintPrice;
    }

    function collectFee() external {
        // To be implemented
    }

    // Private Functions
    function _isSmartContract(address _address) private view returns (bool) {
        // Is this correct?
        return (_address.code.length > 0);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/ICharacter.sol";
import "src/interfaces/IOwnersContract.sol";

// General Doubts of the implementation:
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
    string public tokenURI;
    uint256 public totalSupply;
    uint256 public mintPrice;
    uint256 public defaultRequiredExpirience;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) public allowance;
    mapping(uint256 => Metadata) public metadata;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        address _ownersContract
    ) {
        name = _name;
        symbol = _symbol;
        tokenURI = _tokenURI;
        defaultRequiredExpirience = 100;
        owner = _ownersContract;
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
            _from == msg.sender || allowance[_tokenId] == msg.sender,
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
            msg.sender == _tokenOwner || allowance[_tokenId] == msg.sender,
            "Not the owner"
        );
        allowance[_tokenId] = _approved;
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

    function currentTokenID() external view returns (uint256 _currentTokenID) {
        return totalSupply;
    }

    function setMintingPrice(uint256 _mintPrice) external {
        require(_mintPrice > 0, "Invalid _mintPrice");
        require(msg.sender == owner, "Not the owner");
        mintPrice = _mintPrice;
    }

    function collectFee() external {
        require(msg.sender == owner, "Not the owner");
        // To be implemented
    }

    // Private Functions
    function _isSmartContract(address _address) private view returns (bool) {
        // Is this correct?
        return (_address.code.length > 0);
    }
}

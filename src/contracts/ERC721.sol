//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC721.sol";

contract ERC721 is IERC721 {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    string public tokenURI;
    uint256 public mintPrice;
    uint256 public currentTokenID;

    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) public allowance;
    mapping(uint256 => address) public approved;

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    modifier isValidTokenId(uint256 _tokenId) {
        require(_tokenId > 0 && _tokenId <= totalSupply, "Invalid tokenId");
        _;
    }

    modifier isValidAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI
    ) {
        name = _name;
        symbol = _symbol;
        tokenURI = _tokenURI;
    }

    function safeTransfer(address _to, uint256 _tokenId) external {
        require(ownerOf[_tokenId] == msg.sender, "Not the owner");
        require(
            msg.sender == msg.sender ||
                approved[_tokenId] == msg.sender ||
                allowance[_tokenId] == msg.sender,
            "Not authorized"
        );
        require(_isSmartContract(_to), "Invalid contract");
        // TODO: Validate if the logic to valide if _to is a smart contract is correct
        balanceOf[msg.sender]--;
        balanceOf[_to]++;
        ownerOf[_tokenId] = _to;
        approved[_tokenId] = address(0);
        emit Transfer(msg.sender, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external isValidTokenId(_tokenId) isValidAddress(_to) {
        require(ownerOf[_tokenId] == _from, "Not the owner");
        require(
            msg.sender == _from ||
                approved[_tokenId] == msg.sender ||
                allowance[_tokenId] == msg.sender,
            "Not authorized"
        );
        require(_isSmartContract(_to), "Invalid contract");
        // TODO: Validate if the logic to valide if _to is a smart contract is correct
        balanceOf[_from]--;
        balanceOf[_to]++;
        ownerOf[_tokenId] = _to;
        approved[_tokenId] = address(0);
        emit Transfer(_from, _to, _tokenId);
    }

    function approve(
        address _approved,
        uint256 _tokenId
    ) external isValidTokenId(_tokenId) {
        address _tokenOwner = ownerOf[_tokenId];
        require(
            msg.sender == _tokenOwner ||
                approved[_tokenId] == msg.sender ||
                allowance[_tokenId] == msg.sender,
            "Not authorized"
        );
        approved[_tokenId] = _approved;
        emit Approval(_tokenOwner, _approved, _tokenId);
    }

    function safeMint(string memory _name) external payable {
        // TODO: This funciton needs to be created in Character and Weapon contracts
    }

    function buy(uint256 _tokenId, string memory _newName) external {
        //TODO
    }

    function setOnSale(uint256 _tokenId, bool _onSale) external {
        //TODO
    }

    function setMintPrice(uint256 _mintPrice) external {
        //TODO
    }

    function collectFee() external {
        //TODO
    }

    function _isSmartContract(address _address) private view returns (bool) {
        return (_address.code.length > 0);
    }
}

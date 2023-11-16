//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC721.sol";

contract ERC721 is IERC721 {
    // Events
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

    string public name;
    string public symbol;
    string public tokenURI;
    uint256 public totalSupply;
    uint256 public mintPrice;
    address public ownersContract;

    mapping(address => uint256[]) public tokensOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) public allowance;

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
        string memory _tokenURI,
        address _ownerContract
    ) {
        name = _name;
        symbol = _symbol;
        tokenURI = _tokenURI;
        ownersContract = _ownerContract;
    }

    function safeTransfer(
        address _to,
        uint256 _tokenId
    ) external isValidTokenId(_tokenId) isValidAddress(_to) {
        require(ownerOf[_tokenId] == msg.sender, "Not the owner");
        // TODO: The part of the safe transfer
        ownerOf[_tokenId] = _to;
        balanceOf[msg.sender]--;
        balanceOf[_to]++;
        allowance[_tokenId] = address(0);
        removeTokenFromAddress(msg.sender, _tokenId);
        addTokenToAddress(_to, _tokenId);
        emit Transfer(msg.sender, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external isValidTokenId(_tokenId) isValidAddress(_to) {
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
        removeTokenFromAddress(_from, _tokenId);
        addTokenToAddress(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    function approve(
        address _approved,
        uint256 _tokenId
    ) external isValidTokenId(_tokenId) {
        address _tokenOwner = ownerOf[_tokenId];
        require(
            msg.sender == _tokenOwner || allowance[_tokenId] == msg.sender,
            "Not the owner"
        );
        allowance[_tokenId] = _approved;
    }

    function currentTokenID() external view returns (uint256 _currentTokenID) {
        return totalSupply;
    }

    function addTokenToAddress(address _address, uint256 _tokenId) internal {
        tokensOf[_address].push(_tokenId);
    }

    function removeTokenFromAddress(
        address _address,
        uint256 _tokenId
    ) internal {
        uint256[] storage tokenList = tokensOf[_address];
        for (uint256 i = 0; i < tokenList.length; i++) {
            if (tokenList[i] == _tokenId) {
                tokenList[i] = tokenList[tokenList.length - 1];
                tokenList.pop();
                break;
            }
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/IERC721.sol";
import "src/interfaces/IERC721TokenReceiver.sol";
import "src/interfaces/IOwnersContract.sol";
import "./ERC721TokenReceiver.sol";

import "hardhat/console.sol";

abstract contract ERC721 is IERC721, ERC721TokenReceiver {
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
    uint256 internal maxAmountPerAddress;

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
        address _ownerContract,
        uint256 _maxAmountPerAddress // 0 = unlimited
    ) {
        require(
            bytes(_name).length > 0 &&
                bytes(_symbol).length > 0 &&
                bytes(_tokenURI).length > 0,
            "_name, _symbol and _tokenURI are mandatory parameters"
        );
        require(bytes(_symbol).length == 3, "Invalid symbol");
        require(_ownerContract != address(0), "Invalid address");

        name = _name;
        symbol = _symbol;
        tokenURI = _tokenURI;
        ownersContract = _ownerContract;
        maxAmountPerAddress = _maxAmountPerAddress;
    }

    function safeTransfer(
        address _to,
        uint256 _tokenId
    ) external isValidTokenId(_tokenId) isValidAddress(_to) {
        require(ownerOf[_tokenId] == msg.sender, "Not the owner");
        require(
            maxAmountPerAddress == 0 ||
                maxAmountPerAddress > balanceOf[_to] ||
                IOwnersContract(ownersContract).owners(_to),
            "Max amount reached"
        );
        ownerOf[_tokenId] = _to;
        balanceOf[msg.sender]--;
        balanceOf[_to]++;
        allowance[_tokenId] = address(0);
        removeTokenFromAddress(msg.sender, _tokenId);
        addTokenToAddress(_to, _tokenId);
        emit Transfer(msg.sender, _to, _tokenId);
        this.isERC721TokenReceiver(_to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external isValidTokenId(_tokenId) isValidAddress(_to) {
        require(_tokenId <= totalSupply && _tokenId > 0, "Invalid tokenId");
        require(_to != address(0), "Invalid address");
        require(
            _from == msg.sender ||
                allowance[_tokenId] == msg.sender ||
                IOwnersContract(ownersContract).addressOf("Character") ==
                msg.sender ||
                IOwnersContract(ownersContract).addressOf("Weapon") ==
                msg.sender,
            "Not the owner"
        );
        require(
            maxAmountPerAddress == 0 ||
                balanceOf[_to] < maxAmountPerAddress ||
                IOwnersContract(ownersContract).owners(_to),
            "Max amount reached"
        );
        ownerOf[_tokenId] = _to;
        balanceOf[_from]--;
        balanceOf[_to]++;
        allowance[_tokenId] = address(0);
        removeTokenFromAddress(_from, _tokenId);
        addTokenToAddress(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
        this.isERC721TokenReceiver(_to, _tokenId);
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
        emit Approval(_tokenOwner, _approved, _tokenId);
    }

    function currentTokenID() external view returns (uint256 _currentTokenID) {
        return totalSupply;
    }

    function collectFee() external {
        require(msg.sender == ownersContract, "Not owners contract");
        require(balanceOf[ownersContract] > 0, "zero balance");
        console.log("balance", address(this).balance);
        console.log("total fees", balanceOf[ownersContract]);
        payable(ownersContract).transfer(address(this).balance);
        balanceOf[ownersContract] = 0;
    }

    function setMintPrice(uint256 _mintPrice) external {
        require(
            IOwnersContract(ownersContract).owners(msg.sender),
            "Not the owner"
        );
        mintPrice = _mintPrice;
    }

    /// --------------------
    /// OUR CODE STARTS HERE
    /// --------------------

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

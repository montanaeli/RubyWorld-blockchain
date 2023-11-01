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
        //TODO
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        //TODO
    }

    function approve(address _approved, uint256 _tokenId) external {
        //TODO
    }

    function safeMint(string memory _name) external {
        //TODO
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
}

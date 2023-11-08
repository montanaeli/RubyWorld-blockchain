//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC721 {
    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function tokenURI() external view returns (string memory _tokenURI);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function allowance(uint256 _tokenId) external view returns (address);

    function safeTransfer(address _to, uint256 _tokenId) external;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    function approve(address _approved, uint256 _tokenId) external;

    function currentTokenID() external view returns (uint256 _currentTokenID);

    function mintPrice() external view returns (uint256 _mintPrice);

    function setMintPrice(uint256 _mintPrice) external;
}

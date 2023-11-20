//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC721TokenReceiver {
    /// @notice Indicates that this contract handles the receipt of an NFT.
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    ///  Note: the ERC-165 identifier for this interface is 0x150b7a02 (aka magic number)
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4);

    ///@notice Dev usage of onERC721Received because of repeated conditionals for reverting
    ///@dev Check if the contract address is a smart contract
    ///@dev Check if the contract address implements the onERC721Received interface
    ///@dev Check if the result of onERC721Received is equal to the magic number
    function isERC721TokenReceiver(address _to, uint256 _tokenId) external;
}

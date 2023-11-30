//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC721 {
    /// @notice Return the name of the NFT collection
    function name() external view returns (string memory _name);

    /// @notice Return the symbol of the NFT collection
    function symbol() external view returns (string memory _symbol);

    /// @notice Return the total supply of the NFT collection
    function totalSupply() external view returns (uint256);

    /// @notice Return the amount of NFTs each account owns
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Return the tokenURI of the NFT collection
    function tokenURI() external view returns (string memory _tokenURI);

    /// @notice Returns the owner address for each token index
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Return the approved address to manage on behalf of an NFT owner the indicated index token
    function allowance(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from sender address to address '_to'
    /// Perform the validations in the indicated order:
    /// @dev Throw if `_tokenId` is not a valid NFT identifier with "Invalid tokenId".
    /// @dev Throw if `_to` is the zero address with "Invalid address".
    /// @dev Throw if sender is not the current owner with message "Not the owner".
    /// @dev When transfer is complete, this function checks if `_to` is a smart contract (code size > 0),
    /// if so, it calls `onERC721Received` on `_to` and throws if the return value is not
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    /// @dev Emit the event "Transfer" with the corresponding parameters.
    /// @param _to The address of the new owner
    /// @param _tokenId The NFT identifier to transfer
    function safeTransfer(address _to, uint256 _tokenId) external;

    /// @notice Transfers the ownership of an NFT from address '_from' to address '_to'
    /// Perform the validations in the indicated order:
    /// @dev Throw if `_tokenId` is not a valid NFT identifier with "Invalid tokenId".
    /// @dev Throw if `_to` is the zero address with "Invalid address".
    /// @dev Throw if `_from` is not the current owner with message "Not the owner".
    /// @dev Throw unless sender is the current owner or an authorized address for the NFT, with message
    /// "Not authorized".
    /// @dev When transfer is complete, this function checks if `_to` is a smart contract (code size > 0),
    /// if so, it calls `onERC721Received` on `_to` and throws if the return value is not
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    /// @dev Emit the event "Transfer" with the corresponding parameters.
    /// @param _from The current owner of the NFT
    /// @param _to The address of the new owner
    /// @param _tokenId The NFT identifier to transfer
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    /// Perform the validations in the indicated order:
    /// @dev Throw if `_tokenId` is not a valid NFT identifier. Message: "Invalid tokenId".
    /// @dev Throw unless `msg.sender` is the current NFT owner or an authorized address of the NFT. Message
    /// "Not authorized".
    /// @dev Emit the event "Approval" with the corresponding parameters.
    /// @param _approved The new administrator of the NFT
    /// @param _tokenId The NFT identifier to transfer
    function approve(address _approved, uint256 _tokenId) external;

    /// @dev Returns the index of the last token minted
    function currentTokenID() external view returns (uint256 _currentTokenID);

    /// @dev Returns the current mintage price
    function mintPrice() external view returns (uint256 _mintPrice);

    /// @dev Set the mintage price
    function setMintPrice(uint256 _mintPrice) external;

    /// @dev Transfer to the OwnerContract the total balance in ethers that the contract has accumulated as fees.
    /// @dev This method must be able to be called only by ownersContract, otherwise it will revert with the message "Not owners contract".
    /// @dev In the event that the contract does not have a balance, revert with the message "zero balance".
    function collectFee() external;

    // -----
    // OUR CODE
    // -----

    function totalFees() external view returns (uint256 _totalFees);
}

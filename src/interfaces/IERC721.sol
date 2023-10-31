//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC.sol";

interface IERC721 is IERC {
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

    /// @notice Mint of the NFT
    /// @dev Throw if the name is empty with "Invalid _name"
    /// @dev Throw if sender don't have enough Rubies to cover the price of the token to mint. Message: "Insufficient balance"
    /// @dev Throw if the contract don't have enough allowance to cover the price of the token to mint. Message: "Insufficient allowance"
    /// @dev When mint is complete, this function checks if `_to` is a smart contract (code size > 0),
    /// if so, it calls `onERC721Received` on `_to` and throws if the return value is not
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    /// @param _name The name of the new NFT
    function safeMint(string memory _name) external;

    /// @notice Return the sell metadata for a tokenId
    /// @dev Throw if the tokenId does not exist with "Invalid tokenId"
    /// @param _tokenId The tokenId of the NFT which information is requested
    /// @return _onSale True if the NFT is on sale. False otherwise.
    /// @return _price The price in ethers of the NFT
    /// @return _requiredExperience The required experience of the futur owner to buy the NFT
    function getSellInformation(
        uint256 _tokenId
    )
        external
        view
        returns (bool _onSale, uint256 _price, uint256 _requiredExperience);

    /// @notice Transfer the ownership of a NFT from owner address to sender address
    /// @dev The sender must pay the corresponding sellPrice in Rubies, otherwise Throw with "Not enough Rubies"
    /// @dev Throw if the tokenId does not exist with "Invalid tokenId"
    /// @dev Throw if the NFT is not on sale with "NFT not on sale"
    /// @dev Throw if the sender does not have enough experience to buy the NFT with "Insufficient experience"
    /// @dev Throw if sender don't have enough Rubies to cover the price of the token to buy. Message: "Insufficient balance"
    /// @dev Throw if the contract don't have enough allowance to cover the price of the token to buy. Message: "Insufficient allowance"
    /// @dev If the NFT is equipped to a character, it will be unequipped and then transferred to the new owner.
    /// @dev Set the name of the NFT to _newName
    /// @param _tokenId The tokenId of the NFT to buy
    /// @param _newName The new name of the NFT
    function buy(uint256 _tokenId, string memory _newName) external;

    /// @notice Set a NFT's onSale property to true to allow the sell of the NFT. To false otherwise.
    /// @dev Throw if the tokenId does not exist with "Invalid tokenId"
    function setOnSale(uint256 _tokenId, bool _onSale) external;

    /// @dev Returns the index of the last token minted
    function currentTokenID() external view returns (uint256 _currentTokenID);

    /// @dev Returns the current mintage price
    function mintPrice() external view returns (uint256 _mintPrice);

    /// @dev Set the mintage price
    function setMintPrice(uint256 _mintPrice) external;

    /// @dev Transfer to the OwnerContract the total balance in ethers that the contract has accumulated as fees.
    /// @dev This method must be able to be called only by ownersContract, otherwise it will Throw with the message "Not owners contract".
    /// @dev In the event that the contract does not have a balance, Throw with the message "zero balance".
    function collectFee() external;
}

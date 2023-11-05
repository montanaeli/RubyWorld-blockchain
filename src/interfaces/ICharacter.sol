//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "src/interfaces/IWeapon.sol";

/// @dev NFT interface
interface ICharacter {
    /// @dev Events

    /// @notice Trigger when tokens are transferred
    /// @dev On new tokens creation, trigger with the `from` address set to zero address
    /// @param _from The address of the sender. This field must be indexed.
    /// @param _to The address of the recipient. This field must be indexed.
    /// @param _value The amount of tokens transferred

    /// @notice Trigger on any successful call to `approve` method
    /// @param _owner The address of the owner. This field must be indexed.
    /// @param _spender The address of the approved spender. This field must be indexed.
    /// @param _value The amount of tokens approved

    // Structure metadata
    struct Metadata {
        string name;
        uint256 attackPoints;
        uint256 armorPoints;
        uint256[3] weapon;
        uint256 sellPrice;
        uint256 requiredExperience;
        bool onSale;
    }

    /// @notice Return the name of the NFT collection
    function name() external view returns (string memory _name);

    /// @notice Return the symbol of the NFT collection
    function symbol() external view returns (string memory _symbol);

    /// @notice Return the tokenURI of the NFT collection
    function tokenURI() external view returns (string memory _tokenURI);

    /// @notice Return the total supply of the NFT collection
    function totalSupply() external view returns (uint256);

    /// @notice Return the amount of NFTs each account owns
    function balanceOf(address _owner) external view returns (uint256);

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

    /// @dev Returns the metadata of the character in the indicated index
    function metadataOf(
        uint256 _tokenId
    ) external view returns (Metadata memory _metadata);

    /// @dev Returns the equipped weapon of the character in the indicated index
    function weapon(
        uint256 _weaponIndex
    ) external view returns (IWeapon _weapon);

    /// @notice Mint a new Character NFT with the indicated name
    /// @dev Revert if the name is empty with "Invalid _name"
    /// @dev Revert if sender not pay the corresponding mintPrice with "Not enough ETH"
    /// @dev Each minted characters will start with 100 attackPoints and 50 armorPoints. The rest of
    /// the attributes will be set to default values.
    /// @dev With each new minted character, the owner account will recieve 1000 RUBIE tokens
    /// @dev When mint is complete, this function checks if `_to` is a smart contract (code size > 0),
    /// if so, it calls `onERC721Received` on `_to` and throws if the return value is not
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    /// @param _name The name of the new Character NFT
    function safeMint(string memory _name) external;

    /// @notice Mint a new hero, a character NFT with special attributes
    /// @dev Revert if _attackPoints is less than 100 with "Invalid _attackPoints"
    /// @dev Revert if _armorPoints is less than 50 with "Invalid _armorPoints"
    /// @dev Revert if _sellPrice is zero with "Invalid _sellPrice"
    /// @dev Revert if _requiredExperience is less than 100 with "Invalid _requiredExperience"
    /// @dev The ´name´ must be set to "Hero name"
    /// @dev The ´onSale´ must be set to true
    /// @param _attackPoints The attack points of the new hero
    /// @param _armorPoints The armor points of the new hero
    /// @param _weapon The weapons equiped of the new hero. Up to three weapons.
    /// @param _sellPrice The price in ethers of the new hero
    /// @param _requiredExperience The required experience to buy the new hero
    function mintHero(
        uint256 _attackPoints,
        uint256 _armorPoints,
        uint256[3] memory _weapon, // Took the liberty to change this, already asked David if this is correct.
        uint256 _sellPrice,
        uint256 _requiredExperience
    ) external;

    /// @notice Return the sell metadata for a tokenId
    /// @dev Revert if the tokenId does not exist with "Invalid tokenId"
    /// @param _tokenId The tokenId of the character which information is requested
    /// @return _onSale True if the character is on sale. False otherwise.
    /// @return _price The price in ethers of the character
    /// @return _requiredExperience The required experience of the futur owner to buy the character
    function getSellinformation(
        uint256 _tokenId
    )
        external
        view
        returns (bool _onSale, uint256 _price, uint256 _requiredExperience);

    /// @notice Transfer the ownership of a character from owner address to sender address
    /// @dev The sender must pay the corresponding sellPrice in ETH, otherwise revert with "Not enough ETH"
    /// @dev Revert if the tokenId does not exist with "Invalid tokenId"
    /// @dev Revert if the character is not on sale with "Character not on sale"
    /// @dev Revert if the sender does not have enough experience to buy the character with "Insufficient experience"
    /// @dev If the Character has weapons equiped it will be transfered to the new owner
    /// @dev Set the new name of the character
    /// @param _tokenId The tokenId of the character to buy
    /// @param _newName The new name of the character
    function buy(uint256 _tokenId, string memory _newName) external;

    /// @notice Set a character's onSale property to true to allow the sell of the character. To false otherwise.
    /// @dev Revert if the tokenId does not exist with "Invalid tokenId"
    function setOnSale(uint256 _tokenId, bool _onSale) external;

    /// @dev Returns the index of the last token minted
    function currentTokenID() external view returns (uint256 _currentTokenID);

    /// @dev Returns the current mintage price
    function mintPrice() external view returns (uint256 _mintPrice);

    /// @dev Set the mintage price
    function setMintingPrice(uint256 _mintPrice) external;

    /// @dev Transfer to the OwnerContract the total balance in ethers that the contract has accumulated as fees.
    /// @dev This method must be able to be called only by ownersContract, otherwise it will revert with the message "Not owners contract".
    /// @dev In the event that the contract does not have a balance, revert with the message "zero balance".
    function collectFee() external;
}

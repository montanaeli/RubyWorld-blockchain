//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/// @dev NFT interface
interface IRubie {
    /// @notice Return the name of the token
    function name() external view returns (string memory _name);
    /// @notice Return the symbol of the token
    function symbol() external view returns (string memory _symbol);
    /// @notice Return the decimals of the token
    function decimals() external view returns (uint256 _decimals);
    /// @notice Return the total supply of the token
    function totalSupply() external view returns (uint256);
    /// @notice Return the amount of tokens each account owns
    function balanceOf(address _owner) external view returns (uint256);
    /// @notice Return the amount of tokens that an owner allowed to a spender
    function allowance(address _owner, address _spender) external view returns (uint256 _amount);
    /// @notice Transfers `_value` amount of tokens to address `_to`. 
    /// Perform the validations in the indicated order:
    /// @dev Throw if `_to` is the zero address with "Invalid address".
    /// @dev Throw if `_to` is sender account. Message: "Invalid recipient, same as remittent"
    /// @dev Throw if `_value` is zero. Message: "Invalid _value"
    /// @dev Throw if remittent account has insufficient balance. Message: "Insufficient balance"
    /// @dev When transfer is complete, this function checks if `_to` is a smart contract (code size > 0), 
    /// if so, it calls `onERC721Received` on `_to` and throws if the return value is not 
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    /// @dev On success must fire the `Transfer` event.
    /// @param _to It is the recipient account address
    /// @param _value It is the amount of tokens to transfer.
    function safeTransfer(address _to, uint256 _value) external;
    /// @notice Transfers `_value` amount of tokens from address `_from` to address `_to`.
    /// Perform the validations in the indicated order:
    /// @dev Throw if `_from` is the zero address with "Invalid _from address".
    /// @dev Throw if `_to` is the zero address with "Invalid _to address".
    /// @dev Throw if `_to` is the same as `_from` account. Message: "Invalid recipient, same as remittent"
    /// @dev Throw if `_value` is zero. Message: "Invalid _value"
    /// @dev Throw if `_from` account has insufficient balance. Message: "Insufficient balance"
    /// @dev Throw if `msg.sender` is not the current owner or an approved address with permission to spend 
    /// the balance of the '_from' account Message: "Insufficent allowance"
    /// @dev When transfer is complete, this function checks if `_to` is a smart contract (code size > 0), 
    /// if so, it calls `onERC721Received` on `_to` and throws if the return value is not 
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`, message: "Invalid contract".
    /// @dev On success must fire the `Transfer` event.
    /// @param _from It is the remittent account address
    /// @param _to It is the recipient account address
    /// @param _value It is the amount of tokens to transfer
    function safeTransferFrom(address _from, address _to, uint256 _value) external;
    /// @notice Allows `_spender` to withdraw from sender account multiple times, up to the `_value` amount
    /// Perform the validations in the indicated order:
    /// @dev If this function is called multiple times it overwrites the current allowance with `_value`
    /// @dev Throw if allowance tries to be set to a new value, higher than zero, for the same spender, 
    /// with a current allowance different that zero. Message: "Invalid allowance amount. Set to zero first"
    /// @dev Throw if `_spender` is zero address. Message: "Invalid _spender"
    /// @dev Throw if `_value` exceeds the sender's balance. Message: "Insufficient balance"
    /// On success must fire the `Approval` event.
    /// @param _spender It is the spender account address
    /// @param _value It is the allowance amount.
    function approve(address _spender, uint256 _value) external;
    /// @notice It returns the price of the token expresed in ETH
    function price() external view returns (uint256 _price);
    /// @notice Issues a new amount of tokens
    /// Perform the validations in the indicated order:
    /// @dev Throw if _amount is zero with the message "Invalid _amount"
    /// @dev Throw if `_recipient` is zero address. Message: "Invalid _recipient"
    /// @dev Emit the `Transfer` event with the `_from` parameter set to zero address.
    /// @param _amount It is the amount of tokens to mint
    /// @param _recipient It is the recipient account for the new tokens
    function mint(uint256 _amount, address _recipient) external;
    /// @notice Transfer or issue a number of tokens to the sender account in exchange of a number of ETH
    /// Perform the validations in the indicated order:
    /// @dev Throw if msg.value is insufficent to cover the price of the tokens to buy. Message: "Insufficient ether" 
    /// @dev If the msg.value is higher than the price of the tokens to buy, the function must return the difference
    /// @dev Emit the `Transfer` event with the `_from` parameter set to zero address.
    /// @param _amount It is the amount of tokens to buy
    function buy(uint256 _amount) external;
    /// @notice It sets the price of the token
    /// @dev Throw if _price is zero with the message "Invalid _price"
    /// @param _price It is the new price of the token
    function setPrice(uint256 _price) external;
}
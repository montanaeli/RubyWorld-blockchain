//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/// @dev NFT interface
interface IExperience {
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
    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 _amount);

    /// @notice Transfers `_value` amount of tokens to address `_to`.
    /// Perform the validations in the indicated order:
    /// @dev Throw if `_to` is the zero address with "Invalid address".
    /// @dev Throw if `_to` is sender account. Message: "Invalid recipient, same as remittent"
    /// @dev Throw if `_value` is zero. Message: "Invalid _value"
    /// @dev Throw if remittent account has insufficient balance. Message: "Insufficient balance"
    /// @dev On success must fire the `Transfer` event.
    /// @param _to It is the recipient account address
    /// @param _value It is the amount of tokens to transfer.
    function transfer(address _to, uint256 _value) external returns (bool);

    /// @notice Transfers `_value` amount of tokens from address `_from` to address `_to`.
    /// Perform the validations in the indicated order:
    /// @dev Throw if `_from` is the zero address with "Invalid _from address".
    /// @dev Throw if `_to` is the zero address with "Invalid _to address".
    /// @dev Throw if `_to` is the same as `_from` account. Message: "Invalid recipient, same as remittent"
    /// @dev Throw if `_value` is zero. Message: "Invalid _value"
    /// @dev Throw if `_from` account has insufficient balance. Message: "Insufficient balance"
    /// @dev Throw if `msg.sender` is not the current owner or an approved address with permission to spend
    /// the balance of the '_from' account Message: "Insufficent allowance"
    /// @dev On success must fire the `Transfer` event.
    /// @param _from It is the remittent account address
    /// @param _to It is the recipient account address
    /// @param _value It is the amount of tokens to transfer
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

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

    /// @notice It returns the price of the token expresed in Rubies token
    function price() external view returns (uint256 _price);

    /// @notice Issue a number of tokens in exchange of a number of Rubies tokens
    /// Perform the validations in the indicated order:
    /// @dev Throw if sender don't have enough Rubies to cover the price of the tokens to buy. Message: "Insufficient balance"
    /// @dev Throw if the contract don't have enough allowance to cover the price of the tokens to buy. Message: "Insufficient allowance"
    /// @dev Increase the sell price of the user charater for the 10% of the price.
    /// @dev Increase the armor points of the user charater in 10% of the experience buyed.
    /// @dev Increase the weapon points of the user charater in 5% of the experience buyed.
    /// @dev Emit the `Transfer` event with the corresponding parameters.
    /// @param _amount It is the amount of tokens to buy
    function buy(uint256 _amount) external payable;

    /// @notice It sets the price of the token
    /// @dev Throw if _price is zero with the message "Invalid _price"
    /// @param _price It is the new price of the token
    function setPrice(uint256 _price) external;
}
`
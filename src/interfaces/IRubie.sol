//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC20.sol";

/// @dev NFT interface
interface IRubie is IERC20 {
    /// @notice Transfer or issue a number of tokens to the sender account in exchange of a number of ETH
    /// Perform the validations in the indicated order:
    /// @dev Throw if msg.value is insufficent to cover the price of the tokens to buy. Message: "Insufficient ether"
    /// @dev If the msg.value is higher than the price of the tokens to buy, the function must return the difference
    /// @dev Emit the `Transfer` event with the `_from` parameter set to zero address.
    /// @param _amount It is the amount of tokens to buy
    function buy(uint256 _amount) external payable;
}

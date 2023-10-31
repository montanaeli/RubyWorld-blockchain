//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC20.sol";

interface IRubie is IERC20 {
    /// @notice Issues a new amount of tokens
    /// Perform the validations in the indicated order:
    /// @dev Throw if _amount is zero with the message "Invalid _amount"
    /// @dev Throw if `_recipient` is zero address. Message: "Invalid _recipient"
    /// @dev Emit the `Transfer` event with the `_from` parameter set to zero address.
    /// @param _amount It is the amount of tokens to mint
    /// @param _recipient It is the recipient account for the new tokens
    function mint(uint256 _amount, address _recipient) external;
}

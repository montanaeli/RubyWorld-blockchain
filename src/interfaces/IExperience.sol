//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC20.sol";

interface IExperience is IERC20 {

    /// @notice Issue a number of tokens in exchange of a number of Rubies tokens
    /// Perform the validations in the indicated order:
    /// @dev Throw if sender don't have enough Rubies to cover the price of the tokens to buy. Message: "Insufficient balance"
    /// @dev Throw if the contract don't have enough allowance to cover the price of the tokens to buy. Message: "Insufficient allowance"
    /// @dev Increase the sell price of the user charater for the 10% of the price.
    /// @dev Increase the armor points of the user charater in 10% of the experience buyed.
    /// @dev Increase the weapon points of the user charater in 5% of the experience buyed.  
    /// @dev Emit the `Transfer` event with the corresponding parameters.
    /// @param _amount It is the amount of tokens to buy
    function buy(uint256 _amount) external payable; // CHECK IF PAYABLE IS CORRECT

}

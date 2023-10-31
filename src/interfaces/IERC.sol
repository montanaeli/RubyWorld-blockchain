//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC {
    /// @notice Return the name of the token
    function name() external view returns (string memory _name);

    /// @notice Return the symbol of the token
    function symbol() external view returns (string memory _symbol);

    /// @notice Return the total supply of the token
    function totalSupply() external view returns (uint256);

    /// @notice Return the amount of tokens each account owns
    function balanceOf(address _owner) external view returns (uint256);
}

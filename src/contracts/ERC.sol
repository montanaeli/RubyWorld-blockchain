//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC.sol";

abstract contract ERC is IERC {
    string public name;
    string public symbol;
    uint256 public totalSupply;

    mapping(address => uint256) public override balanceOf;

    modifier isValidAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function name() external view returns (string memory _name) {
        return name;
    }

    function symbol() external view returns (string memory _symbol) {
        return symbol;
    }

    function totalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256) isValidAddress(_owner) {
        return balanceOf[_owner];
    }
}

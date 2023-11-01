//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract ERC {
    string public name;
    string public symbol;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
    }
}

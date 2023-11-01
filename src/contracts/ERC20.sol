//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC20.sol";

contract ERC20 is IERC20 {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public decimals;
    uint256 public price;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        //TODO
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        //TODO
    }

    function approve(address _spender, uint256 _value) external {
        //TODO
    }

    function buy(uint256 _amount) external payable {
        //TODO
    }

    function setPrice(uint256 _price) external {
        //TODO
    }
}

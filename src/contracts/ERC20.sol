//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC20.sol";

contract ERC20 is IERC20 {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public decimals;
    uint256 public price;

    bool success = true;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Modifiers
    modifier isInsuficientBalance(address _account, uint256 _value) {
        require(balanceOf[_account] >= _value, "Insufficient balance");
        _;
    }

    modifier isZeroAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    modifier isValidValue(uint256 _value) {
        require(_value > 0, "Invalid_value");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function transfer(address _to, uint256 _value) external returns (bool) isZeroAddress(_to) isValidValue(_value) {
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return success;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) isZeroAddress(_from) isZeroAddress(_to) isValidValue(_value) {
        require(msg.sender == _from || allowance[_from][msg.sender] >= _value, "Insufficent allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        return success;
    }

    function approve(address _spender, uint256 _value) external isZeroAddress(_to) isValidValue(_value) {
        require(allowance[msg.sender][_spender] == 0 || _value == 0, "Invalid allowance amount. Set to zero first");
        allowance[msg.sender][_spender] = _value;
    }

    function buy(uint256 _amount) external payable {
        //TODO
    }

    function setPrice(uint256 _price) external {
        price = _price;
    }
}

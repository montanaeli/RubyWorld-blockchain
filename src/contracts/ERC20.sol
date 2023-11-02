//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC20.sol";

contract ERC20 is IERC20 {

    /// STATE VARIABLES
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public decimals;
    uint256 public price;

    bool success = true;

    /// STATE MAPPINGS
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /// EVENTS
    /// @notice Trigger when tokens are transferred
    /// @dev On new tokens creation, trigger with the `from` address set to zero address
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    /// @notice Trigger on any successful call to `approve` method
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /// @notice Trigger on any successful call to `burn` method
    event Burn(address indexed _from, address indexed _commandedBy, uint256 _value);

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

    function transfer(address _to, uint256 _value) external isZeroAddress(_to) isValidValue(_value) returns (bool) {

        require(msg.sender != _to, "Invalid recipient, same as remitter");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return success;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external isZeroAddress(_from) isZeroAddress(_to) isValidValue(_value) returns (bool) {

        require(msg.sender == _from || allowance[_from][msg.sender] >= _value, "Insufficent allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        return success;
    }

        function approve(address _spender, uint256 _value) external isZeroAddress(_spender) isValidValue(_value) {
            require(allowance[msg.sender][_spender] == 0 || _value == 0, "Invalid allowance amount. Set to zero first");
            allowance[msg.sender][_spender] = _value;
            
            emit Approval(msg.sender, _spender, _value);
        }

    // Commented because maybe it is not necessary here
    // function buy(uint256 _amount) external payable {
    //     //TODO
    // }

    // function setPrice(uint256 _price) external {
    //     // require(msg.sender == owner, "Not the owner");
    //     // price = _price;
    // }
}

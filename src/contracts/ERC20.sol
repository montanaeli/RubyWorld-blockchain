//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC20.sol";
import "../interfaces/IOwnersContract.sol";

/// @dev The contract is not abstract so we can test it
contract ERC20 is IERC20 {
    /// STATE VARIABLES
    string public name;
    string public symbol;
    address public ownersContract;
    uint256 public totalSupply;
    uint256 public decimals;
    uint256 public price;

    /// STATE MAPPINGS
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /// EVENTS
    /// @notice Trigger when tokens are transferred
    /// @dev On new tokens creation, trigger with the `from` address set to zero address
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @notice Trigger on any successful call to `approve` method
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _ownersContract
    ) {
        require(bytes(_name).length > 0, "Invalid name");
        require(bytes(_symbol).length == 3, "Invalid symbol");
        require(_ownersContract != address(0), "Invalid address");
        name = _name;
        symbol = _symbol;
        ownersContract = _ownersContract;
        price = 1;

        //TODO: Talk with David about this
        uint256 initialSupplyOwners = 10 ** 10;
        totalSupply = initialSupplyOwners;
        balanceOf[address(1)] = initialSupplyOwners;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Invalid address");
        require(msg.sender != _to, "Invalid recipient, same as remitter");
        require(_value > 0, "Invalid _value");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(allowance[msg.sender][_to] >= _value, "Insufficient allowance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        require(_from != address(0), "Invalid _from address");
        require(_to != address(0), "Invalid _to address");
        require(_from != _to, "Invalid recipient, same as remitter");
        require(_value > 0, "Invalid _value");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(
            msg.sender == _from || allowance[_from][_to] >= _value,
            "Insufficent allowance"
        );

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external {
        require(
            (_value > 0 && allowance[msg.sender][_spender] == 0) || _value == 0,
            "Invalid allowance amount. Set to zero first"
        );
        require(_spender != address(0), "Invalid _spender");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
    }

    function setPrice(uint256 _price) external {
        require(_price > 0, "Invalid _price");
        require(
            IOwnersContract(ownersContract).owners(msg.sender),
            "Not the owner"
        );
        price = _price;
    }

    function mint(uint256 _amount, address _recipient) external {
        require(_amount > 0, "Invalid _amount");
        require(_recipient != address(0), "Invalid _recipient");
        require(
            IOwnersContract(ownersContract).owners(msg.sender),
            "Not the owner"
        );

        totalSupply += _amount;
        balanceOf[_recipient] += _amount;

        emit Transfer(address(0), _recipient, _amount);
    }

    //TODO: check, this bypass allowance
    function internalTransferFrom(address _spender, uint256 _value) external {
        allowance[address(1)][_spender] = _value;
        this.transferFrom(address(1), _spender, _value);
        allowance[address(1)][_spender] = 0;
    }
}

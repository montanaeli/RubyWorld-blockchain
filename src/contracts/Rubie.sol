//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";
import "../interfaces/IRubie.sol";
import "../interfaces/IERC20.sol";

contract Rubie is IRubie, ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        address _ownersContract
    ) ERC20(_name, _symbol, _ownersContract) {}

    function mint(uint256 _amount, address _recipient) external {
        require(_amount > 0, "Invalid _amount");
        require(_recipient != address(0), "Invalid _recipient");
        require(msg.sender == ownersContract, "Not the owner");

        totalSupply += _amount;
        balanceOf[_recipient] += _amount;

        emit Transfer(address(0), _recipient, _amount);
    }

    function buy(uint256 _amount) external payable {
        require(msg.value >= (_amount / price), "Insufficient ether");

        if (msg.value > (_amount / price)) {
            payable(msg.sender).transfer(msg.value - (_amount / price));
        }

        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
    }
}

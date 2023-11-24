//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";
import "../interfaces/IRubie.sol";
import "../interfaces/IOwnersContract.sol";
import "../interfaces/IERC20.sol";

contract Rubie is IRubie, ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        address _ownersContract
    ) ERC20(_name, _symbol, _ownersContract) {}

    function buy(uint256 _amount) external payable {
        require(msg.value >= (_amount / price), "Insufficient ether");

        if (msg.value > (_amount / price)) {
            payable(msg.sender).transfer(msg.value - (_amount / price));
        }

        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
    }
}

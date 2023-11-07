//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";
import "../interfaces/IExperience.sol";
import "../interfaces/IRubie.sol";

contract Experience is IExperience, ERC20 {
    IRubie private rubieContract;

    constructor(
        string memory _name,
        string memory _symbol,
        address _ownersContract,
        IRubie _rubieContract
    ) ERC20(_name, _symbol, _ownersContract) {
        rubieContract = _rubieContract;
    }

    function buy(uint256 _amount) external {
        require(
            rubieContract.balanceOf(msg.sender) >= _amount,
            "Insufficient balance"
        );

        require(
            rubieContract.allowance(msg.sender, address(this)) >= _amount,
            "Insufficient allowance"
        );

        //TODO: Check requirements with the team

        emit Transfer(address(this), msg.sender, _amount);
    }
}

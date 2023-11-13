//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";
import "./OwnersContract.sol";
import "./Rubie.sol";
import "../interfaces/IRubie.sol";
import "../interfaces/ICharacter.sol";
import "../interfaces/IExperience.sol";
import "../interfaces/IRubie.sol";

contract Experience is IExperience, ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        address _ownersContract
    ) ERC20(_name, _symbol, _ownersContract) {}

    function buy(uint256 _amount) external {
        address rubieContractAddress = OwnersContract(ownersContract).addressOf(
            "Rubie"
        );

        require(
            Rubie(rubieContractAddress).balanceOf(msg.sender) >= _amount,
            "Insufficient balance"
        );

        require(
            this.allowance(msg.sender, address(this)) >= _amount,
            "Insufficient allowance"
        );

        //TODO: 3 reqs:
        ///1. Increase the sell price of the user charater for the 10% of the price.
        ///2. Increase the armor points of the user charater in 10% of the experience buyed.
        ///3. Increase the weapon points of the user charater in 5% of the experience buyed.

        emit Transfer(address(this), msg.sender, _amount);
    }
}

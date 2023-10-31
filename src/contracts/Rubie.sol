//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IRubie.sol";
import "./ERC20.sol";

abstract contract Rubie is IRubie, ERC20 {

    constructor(string memory _name, string memory _symbol, address _ownersContract) {}
    
}

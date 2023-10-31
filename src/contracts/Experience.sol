//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IExperience.sol";
import "./ERC20.sol";

abstract contract Experience is IExperience, ERC20 {}

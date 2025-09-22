// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {CauseFiToken} from "../abstract/CauseFiToken.a.sol";

contract WrappedCLP is CauseFiToken {
    //
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}
    //
}

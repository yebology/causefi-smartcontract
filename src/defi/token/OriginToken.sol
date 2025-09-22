// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {OFT} from "@layerzerolabs/oft-evm/contracts/OFT.sol";
import {CauseFiToken} from "../abstract/CauseFiToken.a.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OriginToken is CauseFiToken {
    //
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}
    //
}

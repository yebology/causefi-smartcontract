// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OFT} from "@layerzerolabs/oft-evm/contracts/OFT.sol";
import {ACauseFiToken} from "../abstract/ACauseFiToken.a.sol";

contract BaseToken is ACauseFiToken {
    //
    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _owner,
        uint256 _amount,
        uint256 _decimals
    ) OFT(_name, _symbol, _lzEndpoint, _owner) Ownable(_owner) {
        _mint(address(this), _amount * (10 ** _decimals));
    }
    //
}

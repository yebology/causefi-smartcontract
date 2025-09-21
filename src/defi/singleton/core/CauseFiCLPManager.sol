// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {CLP} from "../../token/CLP.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CauseFiCLPManager is Ownable, ReentrancyGuard {
    //
    mapping(address => address) private _pairToCLP;

    constructor(address _owner) Ownable(_owner) {}

    function addCLP(address _pair, address _clpToken) external onlyOwner {
        _pairToCLP[_pair] = _clpToken;
    }

    function lock(address _pair, uint256 _amount) external nonReentrant {
        address clp = getCLP(_pair);
        CLP(clp).mint(address(this), _amount);
    }

    function release(address _pair, uint256 _amount) external {
        address clp = getCLP(_pair);
        CLP(clp).burn(address(this), _amount);
    }

    function getCLP(address _pair) public view returns (address) {
        return _pairToCLP[_pair];
    }

    function totalSupply(address _pair) external view returns (uint256) {
        address clp = getCLP(_pair);
        return CLP(clp).totalSupply();
    }
    //
}

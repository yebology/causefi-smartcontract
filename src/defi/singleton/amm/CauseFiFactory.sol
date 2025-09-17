// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {CauseFiPair} from "./CauseFiPair.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Errors} from "../../lib/Errors.l.sol";
import {Events} from "../../lib/Events.l.sol";
import {ACauseFiToken} from "../../abstract/ACauseFiToken.a.sol";

contract CauseFiFactory is Ownable {
    //
    mapping(address => mapping(address => address)) private s_pair;
    address[] private s_pairAddresses;

    modifier onlyValidToken(address _token0, address _token1) {
        _validateTokenInput(_token0, _token1);
        _;
    }

    constructor(address _owner) Ownable(_owner) {}

    function createPair(
        address _token0,
        address _token1,
        address _clp
    ) external onlyOwner onlyValidToken(_token0, _token1) {
        CauseFiPair pair = new CauseFiPair(_token0, _token1, _clp);

        address pairAddress = address(pair);
        s_pairAddresses.push(pairAddress);

        s_pair[_token0][_token1] = pairAddress;
        s_pair[_token1][_token0] = pairAddress;

        emit Events.PairCreated(pairAddress);
    }

    function getTokenPair(
        address _token0,
        address _token1
    ) external view onlyValidToken(_token0, _token1) returns (address) {
        return s_pair[_token0][_token1];
    }

    function getPairAddresses() external view returns (address[] memory) {
        return s_pairAddresses;
    }

    function _validateTokenInput(
        address _token0,
        address _token1
    ) private pure {
        require(
            (_token0 != _token1 &&
                _token0 != address(0) &&
                _token1 != address(0)),
            Errors.InvalidToken()
        );
    }
    //
}

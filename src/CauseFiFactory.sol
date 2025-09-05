// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {CauseFiPair} from "./CauseFiPair.sol";
import {Errors} from "./lib/Errors.l.sol";
import {Events} from "./lib/Events.l.sol";

contract CauseFiFactory {
    mapping(address => mapping(address => address)) private s_pairs;
    address[] private s_pairAddresses;

    modifier onlyValidToken(address _token0, address _token1) {
        _validateTokenInput(_token0, _token1);
        _;
    }

    function createPair(
        address _token0,
        address _token1
    ) external onlyValidToken(_token0, _token1) {
        CauseFiPair pair = new CauseFiPair(_token0, _token1);

        address pairAddress = address(pair);
        s_pairAddresses.push(pairAddress);

        s_pairs[_token0][_token1] = pairAddress;
        s_pairs[_token1][_token0] = pairAddress;

        emit Events.PairCreated(pairAddress);
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
}

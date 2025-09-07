// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {CauseFiFactory} from "./CauseFiFactory.sol";
import {CauseFiPair} from "./CauseFiPair.sol";
import {ICauseFiPair} from "./CauseFiPair.sol";

contract CauseFiRouter {
    //
    CauseFiFactory private s_factory;

    constructor() {
        s_factory = new CauseFiFactory(msg.sender);
    }

    function addLiquidity(
        address _token0,
        address _token1,
        uint256 _token0Amount,
        uint256 _token1Amount
    ) external returns (uint256) {
        address pair = _getTokenPair(_token0, _token1);

        return ICauseFiPair(pair).addLiquidity(_token0Amount, _token1Amount);
    }

    function removeLiquidity(
        address _token0,
        address _token1,
        uint256 _clpAmount
    ) external returns (uint256, uint256) {
        address pair = _getTokenPair(_token0, _token1);

        return ICauseFiPair(pair).removeLiquidity(_clpAmount);
    }

    function swap(
        address _token0,
        address _token1,
        address _tokenToSwap,
        uint256 _amount
    ) external returns (uint256) {
        address pair = _getTokenPair(_token0, _token1);

        return ICauseFiPair(pair).swap(_tokenToSwap, _amount);
    }

    function _getTokenPair(
        address _token0,
        address _token1
    ) private view returns (address) {
        return s_factory.getTokenPair(_token0, _token1);
    }
    //
}

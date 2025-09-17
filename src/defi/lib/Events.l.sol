// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

library Events {
    event PairCreated(address _pair);

    event LiquidityAdded(
        address _token0,
        uint256 _token0Amount,
        address _token1,
        uint256 _token1Amount,
        uint256 _clpMinted
    );

    event LiquidityRemoved(
        address _token0,
        uint256 _token0Amount,
        address _token1,
        uint256 _token1Amount,
        uint256 _clpAmount
    );

    event TokenSwapped(
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        uint256 _amountOut
    );
}

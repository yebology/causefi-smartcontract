// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

interface ICauseFiPair {
    function addLiquidity(
        uint256 _token0Amount,
        uint256 _token1Amount
    ) external returns (uint256 clpMinted);

    function removeLiquidity(
        uint256 _clpAmount
    ) external returns (uint256 token0Amount, uint256 token1Amount);

    function swap(
        address _token,
        uint256 _amount
    ) external returns (uint256 amountOut);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

interface ICauseFiRouter {
    //
    function sendAddLiquidity(
        address _token0,
        address _token1,
        uint256 _token0Amount,
        uint256 _token1Amount,
        uint32 _dstEid,
        bytes calldata _options
    ) external payable;

    function sendRemoveLiquidity(
        address _token0,
        address _token1,
        uint256 _clpAmount,
        uint32 _dstEid,
        bytes calldata _options
    ) external payable;

    function sendSwapLiquidity(
        address _token0,
        address _token1,
        address _tokenToSwap,
        uint256 _amount,
        uint32 _dstEid,
        bytes calldata _options
    ) external payable;

    
    //
}

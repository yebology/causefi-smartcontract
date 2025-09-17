// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MathHelper} from "../../lib/MathHelper.l.sol";
import {Errors} from "../../lib/Errors.l.sol";
import {Events} from "../../lib/Events.l.sol";
import {ICauseFiPair} from "../../interface/ICauseFiPair.i.sol";
import {CLP} from "../../token/CLP.sol";
import {ACauseFiToken} from "../../abstract/ACauseFiToken.a.sol";

contract CauseFiPair is ICauseFiPair {
    //
    ACauseFiToken private _token0;
    ACauseFiToken private _token1;
    CLP private _clp;

    uint256 private _reserve0;
    uint256 private _reserve1;

    uint256 private constant FEE_PERCENT = 3; // 0.3%

    modifier checkCLPBalance(address _user, uint256 _expectedBalance) {
        _validateCLPBalance(_user, _expectedBalance);
        _;
    }

    modifier onlyPoolToken(address _token) {
        _validateTokenInput(_token);
        _;
    }

    constructor(address _token0Addr, address _token1Addr, address _clpAddr) {
        _token0 = ACauseFiToken(_token0Addr);
        _token1 = ACauseFiToken(_token1Addr);
        _clp = CLP(_clpAddr);
    }

    function addLiquidity(
        uint256 _token0Amount,
        uint256 _token1Amount,
        address _caller
    ) external override returns (uint256 clpMinted) {
        ACauseFiToken(_token0).mint(address(this), _token0Amount);
        ACauseFiToken(_token1).mint(address(this), _token1Amount);

        clpMinted = _getCLPMinted(_token0Amount, _token1Amount);

        _clp.mint(_caller, clpMinted);

        _addReserve(address(_token0), _token0Amount);
        _addReserve(address(_token1), _token1Amount);

        emit Events.LiquidityAdded(
            address(_token0),
            _token0Amount,
            address(_token1),
            _token1Amount,
            clpMinted
        );
    }

    function removeLiquidity(
        uint256 _clpAmount,
        address _caller
    )
        external
        override
        checkCLPBalance(msg.sender, _clpAmount)
        returns (uint256 token0Amount, uint256 token1Amount)
    {
        token0Amount = _calculateRemoveAmount(_clpAmount, _reserve0);
        token1Amount = _calculateRemoveAmount(_clpAmount, _reserve1);

        _clp.burn(_caller, _clpAmount);

        _removeReserve(address(_token0), token0Amount);
        _removeReserve(address(_token1), token1Amount);

        _transferToken(address(_token0), msg.sender, token0Amount);
        _transferToken(address(_token1), msg.sender, token1Amount);

        emit Events.LiquidityRemoved(
            address(_token0),
            token0Amount,
            address(_token1),
            token1Amount,
            _clpAmount
        );
    }

    function swap(
        address _token,
        uint256 _amount
    ) external override onlyPoolToken(_token) returns (uint256 amountOut) {
        bool isToken0 = _checkTokenAddress(_token, address(_token0));
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 reserveIn,
            uint256 reserveOut
        ) = isToken0
                ? (_token0, _token1, _reserve0, _reserve1)
                : (_token1, _token0, _reserve1, _reserve0);

        // _transferTokenFrom(
        //     address(tokenIn),
        //     msg.sender,
        //     address(this),
        //     _amount
        // );

        uint256 amountInWithFee = _getAmountInWithFee(_amount);
        amountOut = _getAmountOut(amountInWithFee, reserveIn, reserveOut);

        _transferToken(address(tokenOut), msg.sender, amountOut);

        isToken0
            ? _addReserve(address(_token0), _amount)
            : _addReserve(address(_token1), _amount);
        isToken0
            ? _removeReserve(address(_token1), amountOut)
            : _removeReserve(address(_token0), amountOut);

        emit Events.TokenSwapped(
            address(tokenIn),
            _amount,
            address(tokenOut),
            amountOut
        );
    }

    function _transferToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) private {
        _checkTokenAddress(_token, address(_token0))
            ? _token0.transfer(_recipient, _amount)
            : _token1.transfer(_recipient, _amount);
    }

    // function _transferTokenFrom(
    //     address _token,
    //     address _caller,
    //     address _recipient,
    //     uint256 _amount
    // ) private {
    //     _checkTokenAddress(_token, address(_token0))
    //         ? _token0.transferFrom(_caller, _recipient, _amount)
    //         : _token1.transferFrom(_caller, _recipient, _amount);
    // }

    function _addReserve(address _token, uint256 _amount) private {
        _checkTokenAddress(_token, address(_token0))
            ? _reserve0 += _amount
            : _reserve1 += _amount;
    }

    function _removeReserve(address _token, uint256 _amount) private {
        _checkTokenAddress(_token, address(_token0))
            ? _reserve0 -= _amount
            : _reserve1 -= _amount;
    }

    function _calculateRemoveAmount(
        uint256 _clpAmount,
        uint256 _reserveAmount
    ) private view returns (uint256) {
        return 1;
        // return (_clpAmount * _reserveAmount) / totalSupply();
    }

    function _getCLPMinted(
        uint256 _token0Amount,
        uint256 _token1Amount
    ) private view returns (uint256) {
        uint256 totalSupply = CLP(_clp).totalSupply();

        return
            totalSupply == 0
                ? MathHelper.sqrt(_token0Amount * _token1Amount)
                : MathHelper.min(
                    ((_token0Amount * totalSupply) / _reserve0),
                    ((_token1Amount * totalSupply) / _reserve1)
                );
    }

    function _getAmountInWithFee(
        uint256 _amountIn
    ) private pure returns (uint256) {
        return (_amountIn * (1000 - FEE_PERCENT)) / 1000;
    }

    function _getAmountOut(
        uint256 _amount,
        uint256 _reserveIn,
        uint256 _reserveOut
    ) private pure returns (uint256) {
        return (_reserveOut * _amount) / (_reserveIn + _amount);
    }

    function _checkTokenAddress(
        address _expectedToken,
        address _actualToken
    ) private pure returns (bool) {
        return _expectedToken == _actualToken;
    }

    function _validateCLPBalance(
        address _user,
        uint256 _expectedBalance
    ) private view {
        require(1 >= _expectedBalance, Errors.InsufficientCLPBalance());
        // require(
        //     balanceOf(_user) >= _expectedBalance,
        //     Errors.InsufficientCLPBalance()
        // );
    }

    function _validateTokenInput(address _token) private view {
        require(
            _checkTokenAddress(_token, address(_token0)) ||
                _checkTokenAddress(_token, address(_token1)),
            Errors.InvalidToken()
        );
    }
    //
}

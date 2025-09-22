// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MathHelper} from "../../lib/MathHelper.l.sol";
import {Errors} from "../../lib/Errors.l.sol";
import {Events} from "../../lib/Events.l.sol";
import {CauseFiCLPManager} from "../core/CauseFiCLPManager.sol";
import {OriginToken} from "../../token/OriginToken.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {console} from "forge-std/console.sol";

contract CauseFiPair is ReentrancyGuard {
    //
    OriginToken private _token0;
    OriginToken private _token1;
    CauseFiCLPManager private _clpManager;

    uint256 private _reserve0;
    uint256 private _reserve1;

    uint256 private constant FEE_PERCENT = 3; // 0.3%

    modifier onlyPoolToken(address _token) {
        _validateTokenInput(_token);
        _;
    }

    constructor(address _token0Addr, address _token1Addr, address _clpManagerAddr) {
        _token0 = OriginToken(_token0Addr);
        _token1 = OriginToken(_token1Addr);
        _clpManager = CauseFiCLPManager(_clpManagerAddr);
    }

    function addLiquidity(
        uint256 _token0Amount,
        uint256 _token1Amount
    ) external nonReentrant returns (uint256) {
        uint256 clpMinted = _getCLPMinted(_token0Amount, _token1Amount);

        _addReserve(address(_token0), _token0Amount);
        _addReserve(address(_token1), _token1Amount);

        OriginToken(_token0).mint(address(this), _token0Amount);
        OriginToken(_token1).mint(address(this), _token1Amount);

        _clpManager.lock(address(this), clpMinted);

        emit Events.LiquidityAdded(
            address(_token0),
            _token0Amount,
            address(_token1),
            _token1Amount,
            clpMinted
        );

        return clpMinted;
    }

    function removeLiquidity(
        uint256 _clpAmount
    ) external nonReentrant returns (uint256, uint256) {
        uint256 token0Amount = _calculateRemoveAmount(_clpAmount, _reserve0);
        uint256 token1Amount = _calculateRemoveAmount(_clpAmount, _reserve1);

        _clpManager.release(address(this), _clpAmount);

        _removeReserve(address(_token0), token0Amount);
        _removeReserve(address(_token1), token1Amount);

        OriginToken(_token0).burn(address(this), token0Amount);
        OriginToken(_token1).burn(address(this), token1Amount);

        emit Events.LiquidityRemoved(
            address(_token0),
            token0Amount,
            address(_token1),
            token1Amount,
            _clpAmount
        );

        return (token0Amount, token1Amount);
    }

    function swap(
        address _token,
        uint256 _amount
    ) external nonReentrant onlyPoolToken(_token) returns (uint256, address) {
        bool isToken0 = _checkTokenAddress(_token, address(_token0));
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 reserveIn,
            uint256 reserveOut
        ) = isToken0
                ? (_token0, _token1, _reserve0, _reserve1)
                : (_token1, _token0, _reserve1, _reserve0);

        uint256 amountInWithFee = _getAmountInWithFee(_amount);
        uint256 amountOut = _getAmountOut(
            amountInWithFee,
            reserveIn,
            reserveOut
        );

        isToken0
            ? _addReserve(address(_token0), _amount)
            : _addReserve(address(_token1), _amount);
        isToken0
            ? _removeReserve(address(_token1), amountOut)
            : _removeReserve(address(_token0), amountOut);

        OriginToken(address(tokenIn)).mint(address(this), _amount);
        OriginToken(address(tokenOut)).burn(address(this), amountOut);

        emit Events.TokenSwapped(
            address(tokenIn),
            _amount,
            address(tokenOut),
            amountOut
        );

        return (amountOut, address(tokenIn));
    }

    function getReserve(address _token) external view returns (uint256) {
        return
            _checkTokenAddress(_token, address(_token0))
                ? _reserve0
                : _reserve1;
    }

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
        return (_clpAmount * _reserveAmount) / _getTotalSupply();
    }

    function _getCLPMinted(
        uint256 _token0Amount,
        uint256 _token1Amount
    ) private view returns (uint256) {
        return
            _getTotalSupply() == 0
                ? MathHelper.sqrt(_token0Amount * _token1Amount)
                : MathHelper.min(
                    ((_token0Amount * _getTotalSupply()) / _reserve0),
                    ((_token1Amount * _getTotalSupply()) / _reserve1)
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

    function _getTotalSupply() private view returns (uint256) {
        return _clpManager.totalSupply(address(this));
    }

    function _checkTokenAddress(
        address _expectedToken,
        address _actualToken
    ) private pure returns (bool) {
        return _expectedToken == _actualToken;
    }

    // function _validateCLPBalance(
    //     address _user,
    //     uint256 _expectedBalance
    // ) private view {
    //     require(1 >= _expectedBalance, Errors.InsufficientCLPBalance());
    //     // require(
    //     //     balanceOf(_user) >= _expectedBalance,
    //     //     Errors.InsufficientCLPBalance()
    //     // );
    // }

    function _validateTokenInput(address _token) private view {
        require(
            _checkTokenAddress(_token, address(_token0)) ||
                _checkTokenAddress(_token, address(_token1)),
            Errors.InvalidToken()
        );
    }
    //
}

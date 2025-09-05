// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MathHelper} from "./lib/MathHelper.l.sol";
import {Errors} from "./lib/Errors.l.sol";

contract AMM is ERC20 {
    //
    IERC20 private token0;
    IERC20 private token1;

    uint256 private reserve0;
    uint256 private reserve1;

    uint256 private constant FEE_PERCENT = 3; // 0.3%

    modifier checkCLPBalance(address _user, uint256 _expectedBalance) {
        _validateCLPBalance(_user, _expectedBalance);
        _;
    }

    modifier onlyPoolToken(address _token) {
        _validateTokenInput(_token);
        _;
    }

    constructor(address _token0, address _token1) ERC20("CauseFi LP", "CLP") {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function addLiquidity(
        uint256 _token0Amount,
        uint256 _token1Amount
    ) external returns (uint256 clpMinted) {
        _transferTokenFrom(
            address(token0),
            msg.sender,
            address(this),
            _token0Amount
        );
        _transferTokenFrom(
            address(token1),
            msg.sender,
            address(this),
            _token1Amount
        );

        clpMinted = _getCLPMinted(_token0Amount, _token1Amount);
        _mint(msg.sender, clpMinted);

        _addReserve(address(token0), _token0Amount);
        _addReserve(address(token1), _token1Amount);
    }

    function removeLiquidity(
        uint256 _clpAmount
    )
        external
        checkCLPBalance(msg.sender, _clpAmount)
        returns (uint256 token0Amount, uint256 token1Amount)
    {
        token0Amount = _calculateRemoveAmount(_clpAmount, reserve0);
        token1Amount = _calculateRemoveAmount(_clpAmount, reserve1);

        _burn(msg.sender, _clpAmount);

        _removeReserve(address(token0), token0Amount);
        _removeReserve(address(token1), token1Amount);

        _transferToken(address(token0), msg.sender, token0Amount);
        _transferToken(address(token1), msg.sender, token1Amount);
    }

    function swap(
        address _token,
        uint256 _amount
    ) external onlyPoolToken(_token) returns (uint256 amountOut) {
        bool isToken0 = _checkTokenAddress(_token, address(token0));
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 reserveIn,
            uint256 reserveOut
        ) = isToken0
                ? (token0, token1, reserve0, reserve1)
                : (token1, token0, reserve1, reserve0);

        _transferTokenFrom(
            address(tokenIn),
            msg.sender,
            address(this),
            _amount
        );

        uint256 amountInWithFee = _getAmountInWithFee(_amount);
        amountOut = _getAmountOut(amountInWithFee, reserveIn, reserveOut);

        _transferToken(address(tokenOut), msg.sender, amountOut);

        isToken0
            ? _addReserve(address(token0), _amount)
            : _addReserve(address(token1), _amount);
        isToken0
            ? _removeReserve(address(token1), amountOut)
            : _removeReserve(address(token0), amountOut);
    }

    function _transferToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) private {
        _checkTokenAddress(_token, address(token0))
            ? token0.transfer(_recipient, _amount)
            : token1.transfer(_recipient, _amount);
    }

    function _transferTokenFrom(
        address _token,
        address _caller,
        address _recipient,
        uint256 _amount
    ) private {
        _checkTokenAddress(_token, address(token0))
            ? token0.transferFrom(_caller, _recipient, _amount)
            : token1.transferFrom(_caller, _recipient, _amount);
    }

    function _addReserve(address _token, uint256 _amount) private {
        _checkTokenAddress(_token, address(token0))
            ? reserve0 += _amount
            : reserve1 += _amount;
    }

    function _removeReserve(address _token, uint256 _amount) private {
        _checkTokenAddress(_token, address(token0))
            ? reserve0 -= _amount
            : reserve1 -= _amount;
    }

    function _calculateRemoveAmount(
        uint256 _clpAmount,
        uint256 _reserveAmount
    ) private view returns (uint256) {
        return (_clpAmount * _reserveAmount) / totalSupply();
    }

    function _getCLPMinted(
        uint256 _token0Amount,
        uint256 _token1Amount
    ) private view returns (uint256) {
        return
            totalSupply() == 0
                ? MathHelper.sqrt(_token0Amount * _token1Amount)
                : MathHelper.min(
                    ((_token0Amount * totalSupply()) / reserve0),
                    ((_token1Amount * totalSupply()) / reserve1)
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
        require(
            balanceOf(_user) >= _expectedBalance,
            Errors.InsufficientCLPBalance()
        );
    }

    function _validateTokenInput(address _token) private view {
        require(
            _checkTokenAddress(_token, address(token0)) ||
                _checkTokenAddress(_token, address(token1)),
            Errors.InvalidToken()
        );
    }
    //
}

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

    uint256 private constant FEE_PERCENT = 3;

    modifier checkCLPBalance(address _user, uint256 _expectedBalance) {
        _validateCLPBalance(_user, _expectedBalance);
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
            msg.sender,
            address(this),
            _token0Amount,
            _token1Amount
        );
        clpMinted = _getCLPMinted(_token0Amount, _token1Amount);
        _mint(msg.sender, clpMinted);
        _addReserve(_token0Amount, _token1Amount);
    }

    function removeLiquidity(
        uint256 _clpAmount
    )
        external
        checkCLPBalance(msg.sender, _clpAmount)
        returns (uint256 tokenAmount0, uint256 tokenAmount1)
    {
        tokenAmount0 = _calculateRemoveAmount(_clpAmount, reserve0);
        tokenAmount1 = _calculateRemoveAmount(_clpAmount, reserve1);
        _burn(msg.sender, _clpAmount);
        _removeReserve(tokenAmount0, tokenAmount1);
        _transferToken(msg.sender, tokenAmount0, tokenAmount1);
    }

    function swap() external {}

    function _transferToken(
        address _recipient,
        uint256 _token0Amount,
        uint256 _token1Amount
    ) private {
        token0.transfer(_recipient, _token0Amount);
        token1.transfer(_recipient, _token1Amount);
    }

    function _transferTokenFrom(
        address _caller,
        address _recipient,
        uint256 _token0Amount,
        uint256 _token1Amount
    ) private {
        token0.transferFrom(_caller, _recipient, _token0Amount);
        token1.transferFrom(_caller, _recipient, _token1Amount);
    }

    function _addReserve(uint256 _token0Amount, uint256 _token1Amount) private {
        reserve0 += _token0Amount;
        reserve1 += _token1Amount;
    }

    function _removeReserve(
        uint256 _token0Amount,
        uint256 _token1Amount
    ) private {
        reserve0 -= _token0Amount;
        reserve1 -= _token1Amount;
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

    function _validateCLPBalance(
        address _user,
        uint256 _expectedBalance
    ) private view {
        require(
            balanceOf(_user) >= _expectedBalance,
            Errors.InsufficientCLPBalance()
        );
    }
    //
}

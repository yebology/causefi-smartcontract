// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {WrappedCLP} from "../token/WrappedCLP.sol";
import {OriginToken} from "../token/OriginToken.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CauseFiWrappedCLPManager is ReentrancyGuard, Ownable {
    //
    mapping(bytes => address) private _wrappedCLP;

    constructor(address _owner) Ownable(_owner) {}

    function addPair(address _token0, address _token1) external onlyOwner {
        bytes memory pairId = _getPairId(_token0, _token1);

        (
            string memory name,
            string memory symbol
        ) = _wrappedTokenDetailGenerator(_token0, _token1);

        WrappedCLP wrapped = new WrappedCLP(name, symbol);

        _wrappedCLP[pairId] = address(wrapped);
    }

    function mint(
        address _token0,
        address _token1,
        address _recipient,
        uint256 _clpAmount
    ) external nonReentrant {
        address wrapped = getWrappedCLP(_token0, _token1);
        WrappedCLP(wrapped).mint(_recipient, _clpAmount);
    }

    function burn(
        address _token0,
        address _token1,
        address _account,
        uint256 _clpAmount
    ) external {
        address wrapped = getWrappedCLP(_token0, _token1);
        WrappedCLP(wrapped).burn(_account, _clpAmount);
    }

    function getWrappedCLP(
        address _token0,
        address _token1
    ) public view returns (address) {
        bytes memory pairId = _getPairId(_token0, _token1);
        return _wrappedCLP[pairId];
    }

    function _wrappedTokenDetailGenerator(
        address _token0,
        address _token1
    ) private view returns (string memory name, string memory symbol) {
        (
            string memory token0Name,
            string memory token0Symbol
        ) = _getOriginTokenDetail(_token0);
        (
            string memory token1Name,
            string memory token1Symbol
        ) = _getOriginTokenDetail(_token1);

        name = string.concat("Wrapped ", token0Name, "x", token1Name);
        symbol = string.concat("w", token0Symbol, "x", token1Symbol);
    }

    function _getOriginTokenDetail(
        address _token
    ) private view returns (string memory name, string memory symbol) {
        name = OriginToken(_token).name();
        symbol = OriginToken(_token).symbol();
    }

    function _getWrappedCLPStatus(
        address _token0,
        address _token1
    ) external view returns (address) {
        bytes memory pairId = _getPairId(_token0, _token1);
        return _wrappedCLP[pairId];
    }

    function _getPairId(
        address _token0,
        address _token1
    ) private pure returns (bytes memory) {
        (address tokenA, address tokenB) = _token0 < _token1
            ? (_token0, _token1)
            : (_token1, _token0);

        return abi.encode(tokenA, tokenB);
    }
    //
}

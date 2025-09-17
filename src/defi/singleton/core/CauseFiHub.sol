// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {CauseFiFactory} from "../amm/CauseFiFactory.sol";
import {CauseFiPair} from "../amm/CauseFiPair.sol";
import {ICauseFiPair} from "../../interface/ICauseFiPair.i.sol";
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {OAppOptionsType3} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Enums} from "../../lib/Enums.l.sol";
import {ICauseFiRegistry} from "../../interface/ICauseFiRegistry.i.sol";

contract CauseFiHub is OApp, OAppOptionsType3 {
    //
    CauseFiFactory private _factory;
    ICauseFiRegistry private _registry;

    constructor(
        address _endpoint,
        address _owner
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        _factory = new CauseFiFactory(msg.sender);
        _registry = ICauseFiRegistry(_owner);
    }

    function quoteSendMsg(
        uint32 _dstEid,
        string calldata _string,
        bytes calldata _options,
        bool _payInLzToken,
        uint16 _msg
    ) public view returns (MessagingFee memory fee) {
        bytes memory _message = abi.encode(_string);
        fee = _quote(
            _dstEid,
            _message,
            combineOptions(_dstEid, _msg, _options),
            _payInLzToken
        );
    }

    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        (uint16 msgType, bytes memory payload) = abi.decode(
            _message,
            (uint16, bytes)
        );

        if (msgType == uint16(Enums.Message.ADD_LIQUIDITY)) {
            (
                address token0,
                address token1,
                uint256 token0Amount,
                uint256 token1Amount,
                address caller
            ) = abi.decode(
                    payload,
                    (address, address, uint256, uint256, address)
                );
            _receiveAddLiquidity(
                token0,
                token1,
                token0Amount,
                token1Amount,
                caller
            );
        } else if (msgType == uint16(Enums.Message.REMOVE_LIQUIDITY)) {
            (
                address token0,
                address token1,
                uint256 clpAmount,
                address caller
            ) = abi.decode(payload, (address, address, uint256, address));
            _receiveRemoveLiquidity(token0, token1, clpAmount, caller);
        } else if (msgType == uint16(Enums.Message.SWAP)) {
            (
                address token0,
                address token1,
                address tokenToSwap,
                uint256 amount
            ) = abi.decode(payload, (address, address, address, uint256));
            _receiveSwap(token0, token1, tokenToSwap, amount);
        }
    }

    function _receiveAddLiquidity(
        address _token0,
        address _token1,
        uint256 _token0Amount,
        uint256 _token1Amount,
        address _caller
    ) private {
        address pair = _getTokenPair(_token0, _token1);

        uint256 clpMinted = ICauseFiPair(pair).addLiquidity(
            _token0Amount,
            _token1Amount,
            _caller
        );
    }

    function _receiveRemoveLiquidity(
        address _token0,
        address _token1,
        uint256 _clpAmount,
        address _caller
    ) private {
        address pair = _getTokenPair(_token0, _token1);

        (uint256 token0Amount, uint256 token1Amount) = ICauseFiPair(pair)
            .removeLiquidity(_clpAmount, _caller);
    }

    function _receiveSwap(
        address _token0,
        address _token1,
        address _tokenToSwap,
        uint256 _amount
    ) private {
        address pair = _getTokenPair(_token0, _token1);

        uint256 amountOut = ICauseFiPair(pair).swap(_tokenToSwap, _amount);
    }

    function _getTokenPair(
        address _token0,
        address _token1
    ) private view returns (address) {
        return _factory.getTokenPair(_token0, _token1);
    }
    //
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {CauseFiFactory} from "../amm/CauseFiFactory.sol";
import {CauseFiPair} from "../amm/CauseFiPair.sol";
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {OAppOptionsType3} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Enums} from "../../lib/Enums.l.sol";
import {CauseFiCLPManager} from "../core/CauseFiCLPManager.sol";
import {CauseFiTokenRegistry} from "./CauseFiTokenRegistry.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {MessagingReceipt} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

contract CauseFiHub is OApp, OAppOptionsType3, ReentrancyGuard {
    //
    CauseFiFactory private _factory;
    CauseFiCLPManager private _clpManager;
    CauseFiTokenRegistry private _registry;

    bytes private constant EMPTY_OPTIONS = "";

    constructor(
        address _endpoint,
        address _owner,
        address _tokenRegistry
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        _factory = new CauseFiFactory(_owner);
        _clpManager = new CauseFiCLPManager(_owner);
        _registry = CauseFiTokenRegistry(_tokenRegistry);
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
                address token0Remote,
                address token1Remote,
                uint256 token0Amount,
                uint256 token1Amount,
                address recipient,
                uint32 remoteEid
            ) = abi.decode(
                    payload,
                    (address, address, uint256, uint256, address, uint32)
                );
            _receiveAddLiquidity(
                token0Remote,
                token1Remote,
                token0Amount,
                token1Amount,
                recipient,
                remoteEid
            );
        } else if (msgType == uint16(Enums.Message.REMOVE_LIQUIDITY)) {
            (
                address token0Remote,
                address token1Remote,
                address recipient,
                uint256 clpAmount,
                uint32 remoteEid
            ) = abi.decode(
                    payload,
                    (address, address, address, uint256, uint32)
                );
            _receiveRemoveLiquidity(
                token0Remote,
                token1Remote,
                recipient,
                clpAmount,
                remoteEid
            );
        } else if (msgType == uint16(Enums.Message.SWAP)) {
            (
                address token0Remote,
                address token1Remote,
                address tokenToSwapRemote,
                address recipient,
                uint256 amount,
                uint32 remoteEid
            ) = abi.decode(
                    payload,
                    (address, address, address, address, uint256, uint32)
                );
            _receiveSwap(
                token0Remote,
                token1Remote,
                tokenToSwapRemote,
                recipient,
                amount,
                remoteEid
            );
        }
    }

    function _receiveAddLiquidity(
        address _token0Remote,
        address _token1Remote,
        uint256 _token0Amount,
        uint256 _token1Amount,
        address _recipient,
        uint32 _remoteEid
    ) private nonReentrant {
        address token0Local = _getLocalToken(_remoteEid, _token0Remote);
        address token1Local = _getLocalToken(_remoteEid, _token1Remote);

        address pair = _getTokenPair(token0Local, token1Local);

        uint256 clpMinted = CauseFiPair(pair).addLiquidity(
            _token0Amount,
            _token1Amount
        );

        bytes memory _message = abi.encode(
            uint16(Enums.Message.ADD_LIQUIDITY),
            _token0Remote,
            _token1Remote,
            _recipient,
            clpMinted
        );

        _lzSend(
            _remoteEid,
            _message,
            EMPTY_OPTIONS,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
    }

    function _receiveRemoveLiquidity(
        address _token0Remote,
        address _token1Remote,
        address _recipient,
        uint256 _clpAmount,
        uint32 _remoteEid
    ) private {
        address token0Local = _getLocalToken(_remoteEid, _token0Remote);
        address token1Local = _getLocalToken(_remoteEid, _token1Remote);

        address pair = _getTokenPair(token0Local, token1Local);

        (uint256 token0Amount, uint256 token1Amount) = CauseFiPair(pair)
            .removeLiquidity(_clpAmount);

        bytes memory _message = abi.encode(
            uint16(Enums.Message.REMOVE_LIQUIDITY),
            _token0Remote,
            _token1Remote,
            token0Amount,
            token1Amount,
            _recipient
        );

        _lzSend(
            _remoteEid,
            _message,
            EMPTY_OPTIONS,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
    }

    function _receiveSwap(
        address _token0Remote,
        address _token1Remote,
        address _tokenToSwap,
        address _recipient,
        uint256 _amount,
        uint32 _remoteEid
    ) private {
        address token0Local = _getLocalToken(_remoteEid, _token0Remote);
        address token1Local = _getLocalToken(_remoteEid, _token1Remote);

        address pair = _getTokenPair(token0Local, token1Local);

        (uint256 amountToMint, address tokenToBurn) = CauseFiPair(pair).swap(
            _tokenToSwap,
            _amount
        );

        (address tokenToBurnRemote, address tokenToMintRemote) = tokenToBurn == token0Local
            ? (_token0Remote, _token1Remote)
            : (_token1Remote, _token0Remote);

        bytes memory _message = abi.encode(
            uint16(Enums.Message.SWAP),
            tokenToBurnRemote,
            _amount,
            tokenToMintRemote,
            amountToMint,
            _recipient
        );

        _lzSend(
            _remoteEid,
            _message,
            EMPTY_OPTIONS,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
    }

    function _getLocalToken(
        uint256 _remoteEid,
        address _remoteToken
    ) private view returns (address) {
        return _registry.getLocalToken(_remoteEid, _remoteToken);
    }

    function _getTokenPair(
        address _token0,
        address _token1
    ) private view returns (address) {
        return _factory.getTokenPair(_token0, _token1);
    }
    //
}

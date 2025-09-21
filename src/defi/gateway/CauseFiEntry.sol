// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {MessagingReceipt} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {OAppOptionsType3} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Enums} from "../lib/Enums.l.sol";
import {BaseToken} from "../token/BaseToken.sol";
import {WrappedCLP} from "../token/WrappedCLP.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {CauseFiCLPManager} from "./CauseFiCLPManager.sol";

contract CauseFiEntry is ReentrancyGuard, OApp, OAppOptionsType3 {
    //
    CauseFiCLPManager private _clpManager;

    constructor(
        address _endpoint,
        address _owner,
        address __clpManager
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        _clpManager = CauseFiCLPManager(__clpManager);
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

    function addLiquidity(
        address _token0,
        address _token1,
        uint256 _token0Amount,
        uint256 _token1Amount,
        uint32 _srcEid,
        uint32 _dstEid,
        bytes calldata _options
    ) external payable nonReentrant returns (MessagingReceipt memory) {
        BaseToken(_token0).burn(msg.sender, _token0Amount);
        BaseToken(_token1).burn(msg.sender, _token1Amount);

        bytes memory _message = abi.encode(
            uint16(Enums.Message.ADD_LIQUIDITY),
            _token0,
            _token1,
            _token0Amount,
            _token1Amount,
            msg.sender,
            _srcEid
        );

        return
            _lzSend(
                _dstEid,
                _message,
                combineOptions(
                    _dstEid,
                    uint16(Enums.Message.ADD_LIQUIDITY),
                    _options
                ),
                MessagingFee(msg.value, 0),
                payable(msg.sender)
            );
    }

    function removeLiquidity(
        address _token0,
        address _token1,
        uint256 _clpAmount,
        uint32 _dstEid,
        bytes calldata _options
    ) external payable returns (MessagingReceipt memory) {
        bytes memory _message = abi.encode(_token0, _token1, _clpAmount);

        return
            _lzSend(
                _dstEid,
                _message,
                combineOptions(
                    _dstEid,
                    uint16(Enums.Message.REMOVE_LIQUIDITY),
                    _options
                ),
                MessagingFee(msg.value, 0),
                payable(msg.sender)
            );
    }

    function swap(
        address _token0,
        address _token1,
        address _tokenToSwap,
        uint256 _amount,
        uint32 _dstEid,
        bytes calldata _options
    ) external payable returns (MessagingReceipt memory) {
        bytes memory _message = abi.encode(
            _token0,
            _token1,
            _tokenToSwap,
            _amount
        );

        return
            _lzSend(
                _dstEid,
                _message,
                combineOptions(_dstEid, uint16(Enums.Message.SWAP), _options),
                MessagingFee(msg.value, 0),
                payable(msg.sender)
            );
    }

    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*guid*/,
        bytes calldata _message,
        address, // Executor address as specified by the OApp.
        bytes calldata // Any extra data or options to trigger on receipt.
    ) internal override {
        (uint16 msgType, bytes memory payload) = abi.decode(
            _message,
            (uint16, bytes)
        );

        if (msgType == uint16(Enums.Message.ADD_LIQUIDITY)) {
            (
                address token0,
                address token1,
                address recipient,
                uint256 clpAmount
            ) = abi.decode(payload, (address, address, address, uint256));
            _receiveAddLiquidity(token0, token1, recipient, clpAmount);
        }
    }

    function _receiveAddLiquidity(
        address _token0,
        address _token1,
        address _recipient,
        uint256 _clpAmount
    ) private {
        _clpManager.mint(_token0, _token1, _recipient, _clpAmount);
    }
    //
}

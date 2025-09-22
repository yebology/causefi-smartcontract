// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CauseFiTokenRegistry is Ownable {
    //
    mapping(uint32 => mapping(address => address)) private _remoteToLocal;

    constructor(address _owner) Ownable(_owner) {}

    function addPair(
        uint32 _remoteChainEid,
        address _remoteToken,
        address _localToken
    ) external onlyOwner {
        _remoteToLocal[_remoteChainEid][_remoteToken] = _localToken;
    }

    function getLocalToken(
        uint32 _remoteChainEid,
        address _remoteToken
    ) external view returns (address) {
        return _remoteToLocal[_remoteChainEid][_remoteToken];
    }
    //
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CauseFiTokenRegistry is Ownable {
    //
    mapping(uint256 => mapping(address => address)) private _remoteToLocal;

    constructor() Ownable(msg.sender) {}

    function addPair(
        uint256 _remoteChainEid,
        address _remoteToken,
        address _localToken
    ) external onlyOwner {
        _remoteToLocal[_remoteChainEid][_remoteToken] = _localToken;
    }

    function getLocalToken(
        uint256 _remoteChainEid,
        address _remoteToken
    ) external view returns (address) {
        return _remoteToLocal[_remoteChainEid][_remoteToken];
    }
    //
}

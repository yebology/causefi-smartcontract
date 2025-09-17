// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

interface ICauseFiRegistry {
    //
    function addRegistry(
        string memory _tokenName,
        uint16 _chainId,
        address _tokenAddr
    ) external;

    function getTokenAddress(
        bytes32 _tokenId,
        uint16 _chainEid
    ) external view returns (address);

    function getTokenChains(
        bytes32 _tokenId
    ) external view returns (uint16[] memory);
    //
}

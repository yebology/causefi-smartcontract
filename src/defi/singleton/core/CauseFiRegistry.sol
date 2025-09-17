// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.29;

// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// import {ICauseFiRegistry} from "../interface/ICauseFiRegistry.i.sol";

// contract CauseFiRegistry is ICauseFiRegistry, Ownable {
//     //
//     struct TokenInfo {
//         uint16[] chainEids;
//         mapping(uint16 => address) chainAddr;
//     }

//     mapping(bytes32 => TokenInfo) private _tokens;

//     constructor(address _owner) Ownable(_owner) {}

//     function addRegistry(
//         string memory _tokenName,
//         uint16 _chainId,
//         address _tokenAddr
//     ) external override onlyOwner {
//         bytes32 tokenId = keccak256(abi.encodePacked(_tokenName));
//         TokenInfo storage tokenInfo = _tokens[tokenId];
//         tokenInfo.chainAddr[_chainId] = _tokenAddr;
//         tokenInfo.chainEids.push(_chainId);
//     }

//     function getTokenAddress(
//         bytes32 _tokenId,
//         uint16 _chainEid
//     ) external view override returns (address) {
//         return _tokens[_tokenId].chainAddr[_chainEid];
//     }

//     function getTokenChains(
//         bytes32 _tokenId
//     ) external view override returns (uint16[] memory) {
//         return _tokens[_tokenId].chainEids;
//     }
//     //
// }

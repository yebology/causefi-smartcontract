// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Test} from "forge-std/Test.sol";
import {CauseFiTokenRegistry} from "../../../src/defi/singleton/core/CauseFiTokenRegistry.sol";

contract CauseFiTokenRegistryTest is Test {
    // 
    CauseFiTokenRegistry private _registry;

    address private constant BOB = address(1);

    address private constant REMOTE_CHAIN = address(2);
    address private constant LOCAL_CHAIN = address(3);

    uint32 private constant REMOTE_EID = 3000;

    function setUp() public {
        vm.startPrank(BOB);
        _registry = new CauseFiTokenRegistry(BOB);
        vm.stopPrank();
    }

    function testSuccessfullyAddPair() public {
        vm.startPrank(BOB);
        _registry.addPair(REMOTE_EID, REMOTE_CHAIN, LOCAL_CHAIN);
        vm.stopPrank();

        address actualLocalChain = _registry.getLocalToken(REMOTE_EID, REMOTE_CHAIN);

        assertEq(actualLocalChain, LOCAL_CHAIN);
    }
    //
}
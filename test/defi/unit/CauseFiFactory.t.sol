// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Test} from "forge-std/Test.sol";
import {CauseFiFactory} from "../../../src/defi/singleton/amm/CauseFiFactory.sol";
import {Errors} from "../../../src/defi/lib/Errors.l.sol";

contract CauseFiFactoryTest is Test {
    //
    CauseFiFactory private _factory;

    address private constant BOB = address(1);

    address private constant TOKEN_A = address(2);
    address private constant TOKEN_B = address(3);
    address private constant BANK = address(4);

    function setUp() public {
        vm.startPrank(BOB);
        _factory = new CauseFiFactory(BOB);
        vm.stopPrank();
    }

    function testSuccessfullyCreatePair() public {
        vm.startPrank(BOB);
        _factory.createPair(TOKEN_A, TOKEN_B, BANK);
        vm.stopPrank();

        address pairOrdered = _factory.getTokenPair(TOKEN_A, TOKEN_B);
        address pairReversed = _factory.getTokenPair(TOKEN_B, TOKEN_A);

        uint256 expectedPairAddressesLength = 1;
        uint256 actualPairAddressesLength = _factory.getPairAddresses().length;

        assertEq(pairOrdered, pairReversed);
        assertEq(expectedPairAddressesLength, actualPairAddressesLength);
    }

    function testRevertIfInvalidToken() public {
        vm.startPrank(BOB);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidToken.selector
            )
        );
        _factory.createPair(address(0), TOKEN_B, BANK);
        vm.stopPrank();
    }
    //
}

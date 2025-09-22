// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Test} from "forge-std/Test.sol";
import {CauseFiWrappedCLPManager} from "../../../src/defi/gateway/CauseFiWrappedCLPManager.sol";
import {WrappedCLP} from "../../../src/defi/token/WrappedCLP.sol";
import {OriginToken} from "../../../src/defi/token/OriginToken.sol";

contract CauseFiWrappedCLPManagerTest is Test {
    //
    CauseFiWrappedCLPManager private _wCLPManager;
    OriginToken private _arbToken;
    OriginToken private _optToken;

    address private constant BOB = address(1);

    uint256 private constant AMOUNT = 100 * (10 ** 18);

    function setUp() public {
        vm.startPrank(BOB);
        _wCLPManager = new CauseFiWrappedCLPManager(BOB);
        vm.stopPrank();

        _arbToken = new OriginToken("ARBITRUM", "ARB");
        _optToken = new OriginToken("OPTIMISM", "OPT");
    }

    function testSuccessfullyAddPair() public {
        vm.startPrank(BOB);
        _wCLPManager.addPair(address(_arbToken), address(_optToken));
        vm.stopPrank();

        address wrapped = _wCLPManager.getWrappedCLP(
            address(_arbToken),
            address(_optToken)
        );

        string memory expectedName = "Wrapped ARBITRUMxOPTIMISM";
        string memory actualName = WrappedCLP(wrapped).name();

        string memory expectedSymbol = "wARBxOPT";
        string memory actualSymbol = WrappedCLP(wrapped).symbol();

        assertEq(
            keccak256(abi.encodePacked(expectedName)),
            keccak256(abi.encodePacked(actualName))
        );
        assertEq(
            keccak256(abi.encodePacked(expectedSymbol)),
            keccak256(abi.encodePacked(actualSymbol))
        );
    }

    function testSuccessfullyMintWrappedCLP() public {
        vm.startPrank(BOB);
        _wCLPManager.addPair(address(_arbToken), address(_optToken));
        vm.stopPrank();

        _wCLPManager.mint(address(_arbToken), address(_optToken), BOB, AMOUNT);

        address wrapped = _wCLPManager.getWrappedCLP(
            address(_arbToken),
            address(_optToken)
        );

        uint256 actualBobBalance = WrappedCLP(wrapped).balanceOf(BOB);

        assertEq(AMOUNT, actualBobBalance);
    }

    function testSuccessfullyBurnWrappedCLP() public {
        vm.startPrank(BOB);
        _wCLPManager.addPair(address(_arbToken), address(_optToken));
        vm.stopPrank();

        _wCLPManager.mint(address(_arbToken), address(_optToken), BOB, AMOUNT);
        _wCLPManager.burn(address(_arbToken), address(_optToken), BOB, AMOUNT);

        address wrapped = _wCLPManager.getWrappedCLP(
            address(_arbToken),
            address(_optToken)
        );

        uint256 expectedBobBalance = 0;
        uint256 actualBobBalance = WrappedCLP(wrapped).balanceOf(BOB);

        assertEq(expectedBobBalance, actualBobBalance);
    }
    //
}

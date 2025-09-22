// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {CauseFiPair} from "../../../src/defi/singleton/amm/CauseFiPair.sol";
import {OriginToken} from "../../../src/defi/token/OriginToken.sol";
import {CauseFiCLPManager} from "../../../src/defi/singleton/core/CauseFiCLPManager.sol";
import {CLP} from "../../../src/defi/token/CLP.sol";

contract CauseFiPairTest is Test {
    //
    CauseFiPair private _pair;
    CauseFiCLPManager private _clpManager;

    OriginToken private _arbToken;
    OriginToken private _optToken;
    CLP private _clp;

    address private constant BOB = address(1);
    address private constant ALICE = address(2);

    uint256 private constant AMOUNT_TO_ADD_ARB = 100 ** 18;
    uint256 private constant AMOUNT_TO_ADD_OPT = 90 ** 18;

    function setUp() public {
        _arbToken = new OriginToken("ARBITRUM", "ARB");
        _optToken = new OriginToken("OPTIMISM", "OPT");

        _clp = new CLP("CLP ARBITRUMxOPTIMISM", "CLP ARBxOPT");

        vm.startPrank(BOB);
        _clpManager = new CauseFiCLPManager(BOB);
        vm.stopPrank();

        _pair = new CauseFiPair(
            address(_arbToken),
            address(_optToken),
            address(_clpManager)
        );
    }

    function testSucessfullyAddPair() public {
        vm.startPrank(BOB);
        _clpManager.addCLP(address(_pair), address(_clp));
        vm.stopPrank();

        address expectedCLPAddress = address(_clp);
        address actualCLPAddress = _clpManager.getCLP(address(_pair));

        assertEq(expectedCLPAddress, actualCLPAddress);
    }

    function testSuccessfullyAddLiquidity() public {
        vm.startPrank(BOB);
        _clpManager.addCLP(address(_pair), address(_clp));
        vm.stopPrank();

        uint256 expectedCLPMinted = _pair.addLiquidity(
            AMOUNT_TO_ADD_ARB,
            AMOUNT_TO_ADD_OPT
        );
        uint256 actualCLPMinted = _clpManager.totalSupply(address(_pair));

        uint256 expectedARBReserve = AMOUNT_TO_ADD_ARB;
        uint256 actualARBReserve = _pair.getReserve(address(_arbToken));

        uint256 expectedOPTReserve = AMOUNT_TO_ADD_OPT;
        uint256 actualOPTReserve = _pair.getReserve(address(_optToken));

        assertEq(expectedARBReserve, actualARBReserve);
        assertEq(expectedOPTReserve, actualOPTReserve);
        assertEq(expectedCLPMinted, actualCLPMinted);
    }

    function testSuccessfullyRemoveLiquidity() public {
        vm.startPrank(BOB);
        _clpManager.addCLP(address(_pair), address(_clp));
        vm.stopPrank();

        uint256 actualCLPMinted = _pair.addLiquidity(
            AMOUNT_TO_ADD_ARB,
            AMOUNT_TO_ADD_OPT
        );

        (uint256 actualTokenAmount0, uint256 actualTokenAmount1) = _pair
            .removeLiquidity(actualCLPMinted);

        uint256 expectedARBReserve = 0;
        uint256 actualARBReserve = _pair.getReserve(address(_arbToken));

        uint256 expectedOPTReserve = 0;
        uint256 actualOPTReserve = _pair.getReserve(address(_optToken));

        uint256 expectedCLPLeft = 0;
        uint256 actualCLPLeft = _clp.totalSupply();

        assertEq(expectedARBReserve, actualARBReserve);
        assertEq(expectedOPTReserve, actualOPTReserve);
        assertEq(AMOUNT_TO_ADD_ARB, actualTokenAmount0);
        assertEq(AMOUNT_TO_ADD_OPT, actualTokenAmount1);
        assertEq(expectedCLPLeft, actualCLPLeft);
    }

    function testSuccessfullySwap() public {
        vm.startPrank(BOB);
        _clpManager.addCLP(address(_pair), address(_clp));
        vm.stopPrank();

        _pair.addLiquidity(AMOUNT_TO_ADD_ARB, AMOUNT_TO_ADD_OPT);

        uint256 amountToSwap = 10 ** 18;

        uint256 tokenOutSupplyBefore = OriginToken(_optToken).balanceOf(
            address(_pair)
        );

        (uint256 amountOut, address tokenIn) = _pair.swap(
            address(_arbToken),
            amountToSwap
        );

        uint256 tokenOutSupplyAfter = OriginToken(_optToken).balanceOf(
            address(_pair)
        );

        assertEq(address(_arbToken), tokenIn);
        assertEq(tokenOutSupplyBefore - tokenOutSupplyAfter, amountOut);
    }
    //
}

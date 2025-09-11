// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Script} from "forge-std/Script.sol";
import {CauseFiOFT} from "../src/CauseFiOFT.sol";

contract CauseFiOFTScript is Script {
    //
    function run(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _owner
    ) external {
        // uint256 privKey = vm.envUint("PRIVATE_KEY");
        // address pubKey = vm.addr(privKey);

        vm.startBroadcast();
        CauseFiOFT oft = new CauseFiOFT(_name, _symbol, _lzEndpoint, _owner);
        vm.stopBroadcast();
    }
    //
}

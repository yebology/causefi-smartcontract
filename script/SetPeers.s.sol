// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "forge-std/Script.sol";

/// @title LayerZero OApp Peer Configuration Script
/// @notice Sets up peer connections between OApp deployments on different chains
contract SetPeers is Script {
    function run(
        string memory _oappAddr,
        string memory _signer,
        string memory _chain1Eid,
        string memory _chain1Peer,
        string memory _chain2Eid,
        string memory _chain2Peer,
        string memory _chain3Eid,
        string memory _chain3Peer
    ) external {
        // Load environment variables
        address oapp = vm.envAddress(_oappAddr); // Your OApp contract address
        address signer = vm.envAddress(_signer); // Address with owner permissions

        // Example: Set peers for different chains
        // Format: (chain EID, peer address in bytes32)
        (uint32 eid1, bytes32 peer1) = (
            uint32(vm.envUint(_chain1Eid)),
            bytes32(uint256(uint160(vm.envAddress(_chain1Peer))))
        );
        (uint32 eid2, bytes32 peer2) = (
            uint32(vm.envUint(_chain2Eid)),
            bytes32(uint256(uint160(vm.envAddress(_chain2Peer))))
        );
        (uint32 eid3, bytes32 peer3) = (
            uint32(vm.envUint(_chain3Eid)),
            bytes32(uint256(uint160(vm.envAddress(_chain3Peer))))
        );

        vm.startBroadcast(signer);

        // Set peers for each chain
        // CauseFiOFT(oapp).setPeer(eid1, peer1);
        // CauseFiOFT(oapp).setPeer(eid2, peer2);
        // CauseFiOFT(oapp).setPeer(eid3, peer3);

        vm.stopBroadcast();
    }
}

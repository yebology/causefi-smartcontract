// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "forge-std/Script.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

// LayerZero Endpoint v2 interface
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

/// @title LayerZero Library Configuration Script
/// @notice Sets up send and receive libraries for OFT messaging
contract SetLibraries is Script {
    /// @notice Runs the LayerZero library configuration
    function run(
        string memory _endpointAddress,
        string memory _oftAddress,
        string memory _signer,
        string memory _sendLibAddress,
        string memory _receiveLibAddress,
        string memory _destinationEid,
        string memory _sourceEid,
        string memory _gracePeriod
    ) external {
        // Load environment variables
        address endpoint = vm.envAddress(_endpointAddress); // LayerZero Endpoint
        address oft = vm.envAddress(_oftAddress); //  OFT contract
        address signer = vm.envAddress(_signer); // Admin wallet

        // Library addresses
        address sendLib = vm.envAddress(_sendLibAddress); // SendUln302
        address receiveLib = vm.envAddress(_receiveLibAddress); // ReceiveUln302

        // Chain configurations
        uint32 dstEid = uint32(vm.envUint(_destinationEid)); // Destination chain EID
        uint32 srcEid = uint32(vm.envUint(_sourceEid)); // Source chain EID
        uint32 gracePeriod = uint32(vm.envUint(_gracePeriod)); // Grace period in seconds

        vm.startBroadcast(signer);

        // Set send library for outbound messages
        ILayerZeroEndpointV2(endpoint).setSendLibrary(
            oft, // your OFT contract
            dstEid, // destination chain EID
            sendLib // SendUln302 address
        );

        // Set receive library for outbound messages
        ILayerZeroEndpointV2(endpoint).setReceiveLibrary(
            oft, // your OFT contract
            srcEid, // source chain EID
            receiveLib, // ReceiveUln302 address
            gracePeriod // grace period for switching libraries
        );

        vm.stopBroadcast();
    }
}

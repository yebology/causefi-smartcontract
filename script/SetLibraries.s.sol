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
        string memory _endpointAddr,
        string memory _oappAddr,
        string memory _signer,
        string memory _sendLibAddr,
        string memory _receiveLibAddr,
        string memory _dstEid,
        string memory _srcEid,
        string memory _gracePeriod
    ) external {
        // Load environment variables
        address endpoint = vm.envAddress(_endpointAddr); // LayerZero Endpoint
        address oapp = vm.envAddress(_oappAddr); //  OApp contract
        address signer = vm.envAddress(_signer); // Admin wallet

        // Library addresses
        address sendLib = vm.envAddress(_sendLibAddr); // SendUln302
        address receiveLib = vm.envAddress(_receiveLibAddr); // ReceiveUln302

        // Chain configurations
        uint32 dstEid = uint32(vm.envUint(_dstEid)); // Destination chain EID
        uint32 srcEid = uint32(vm.envUint(_srcEid)); // Source chain EID
        uint32 gracePeriod = uint32(vm.envUint(_gracePeriod)); // Grace period in seconds

        vm.startBroadcast(signer);

        // Set send library for outbound messages
        ILayerZeroEndpointV2(endpoint).setSendLibrary(
            oapp, // your OApp contract
            dstEid, // destination chain EID
            sendLib // SendUln302 address
        );

        // Set receive library for outbound messages
        ILayerZeroEndpointV2(endpoint).setReceiveLibrary(
            oapp, // your OApp contract
            srcEid, // source chain EID
            receiveLib, // ReceiveUln302 address
            gracePeriod // grace period for switching libraries
        );

        vm.stopBroadcast();
    }
}

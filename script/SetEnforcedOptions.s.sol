// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {EnforcedOptionParam} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

/// @title LayerZero OApp Enforced Options Configuration Script
/// @notice Sets enforced execution options for specific message types and destinations
contract SetEnforcedOptions is Script {
    using OptionsBuilder for bytes;

    function run(
        string memory _oappAddr,
        string memory _signer,
        string memory _dstEid1,
        string memory _dstEid2
    ) external {
        // Load environment variables
        address oapp = vm.envAddress(_oappAddr); // Your OApp contract address
        address signer = vm.envAddress(_signer); // Address with owner permissions

        // Destination chain configurations
        uint32 dstEid1 = uint32(vm.envUint(_dstEid1)); // First destination EID
        uint32 dstEid2 = uint32(vm.envUint(_dstEid2)); // Second destination EID

        // Message type (should match your contract's constant)
        uint16 SEND = 1; // Message type for sendString function

        // Build options using OptionsBuilder
        bytes memory options1 = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(80000, 0);
        bytes memory options2 = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(100000, 0);

        // Create enforced options array
        EnforcedOptionParam[]
            memory enforcedOptions = new EnforcedOptionParam[](2);

        // Set enforced options for first destination
        enforcedOptions[0] = EnforcedOptionParam({
            eid: dstEid1,
            msgType: SEND,
            options: options1
        });

        // Set enforced options for second destination
        enforcedOptions[1] = EnforcedOptionParam({
            eid: dstEid2,
            msgType: SEND,
            options: options2
        });

        vm.startBroadcast(signer);

        // Set enforced options on the OApp
        // CauseFiOFT(oapp).setEnforcedOptions(enforcedOptions);

        vm.stopBroadcast();
    }
}

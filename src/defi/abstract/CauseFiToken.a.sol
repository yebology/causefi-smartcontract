// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

// import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
// import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
// import {MessagingFee, MessagingReceipt} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
// import {OFTReceipt} from "@layerzerolabs/oft-evm/contracts/OFTCore.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// import {OFT} from "@layerzerolabs/oft-evm/contracts/OFT.sol";
// import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
// import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
// import {MessagingFee, MessagingReceipt} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
// import {OFTReceipt} from "@layerzerolabs/oft-evm/contracts/OFTCore.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract CauseFiToken is ERC20 {
    //
    // using OptionsBuilder for bytes;

    function mint(address _to, uint256 _amount) public virtual {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public virtual {
        _burn(_from, _amount);
    }

    // function sendToken(
    //     uint32 _dstEid,
    //     address _to,
    //     uint256 _amount
    // ) public virtual {
    //     // Build send parameters
    //     bytes memory extraOptions = OptionsBuilder
    //         .newOptions()
    //         .addExecutorLzReceiveOption(65000, 0);

    //     SendParam memory sendParam = SendParam({
    //         dstEid: _dstEid,
    //         to: addressToBytes32(_to),
    //         amountLD: _amount,
    //         minAmountLD: (_amount * 95) / 100, // 5% slippage tolerance
    //         extraOptions: extraOptions,
    //         composeMsg: "",
    //         oftCmd: ""
    //     });

    //     MessagingFee memory fee = this.quoteSend(sendParam, false);

    //     (
    //         MessagingReceipt memory msgReceipt,
    //         OFTReceipt memory oftReceipt
    //     ) = this.send{value: fee.nativeFee}(sendParam, fee, msg.sender);

    //     require(msgReceipt.fee.nativeFee <= fee.nativeFee, "");
    //     require(oftReceipt.amountSentLD == _amount, "");
    // }

    // function addressToBytes32(
    //     address _addr
    // ) internal pure virtual returns (bytes32) {
    //     return bytes32(uint256(uint160(_addr)));
    // }
    //
}

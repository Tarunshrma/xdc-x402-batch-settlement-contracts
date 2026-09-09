// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

/// @title VerifyReadAbi
/// @notice Raw eth_call proof for facilitator channel-state getters.
///
///      forge script script/VerifyReadAbi.s.sol --rpc-url $XDC_APOTHEM_RPC_URL
///
///      Optional env:
///        X402_BATCH_SETTLEMENT  (default canonical CREATE2 address)
///        CHANNEL_ID             (bytes32 hex, default zero)
contract VerifyReadAbi is Script {
    address internal constant DEFAULT_SETTLEMENT = 0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003;

    bytes4 internal constant CHANNELS_SELECTOR = 0x7a7ebd7b;
    bytes4 internal constant PENDING_WITHDRAWALS_SELECTOR = 0xb7f06ebe;
    bytes4 internal constant REFUND_NONCE_SELECTOR = 0xf0dc792e;

    function run() public view {
        address settlement = vm.envOr("X402_BATCH_SETTLEMENT", DEFAULT_SETTLEMENT);
        bytes32 channelId = vm.envOr("CHANNEL_ID", bytes32(0));

        console2.log("============================================================");
        console2.log("  Read ABI proof");
        console2.log("============================================================");
        console2.log("chainId", block.chainid);
        console2.log("settlement", settlement);
        console2.log("settlement code size", settlement.code.length);
        console2.log("channelId", vm.toString(channelId));

        require(settlement.code.length > 0, "VerifyReadAbi: no bytecode at settlement address");

        _callAndLog("channels(bytes32)", CHANNELS_SELECTOR, channelId, 64);
        _callAndLog("pendingWithdrawals(bytes32)", PENDING_WITHDRAWALS_SELECTOR, channelId, 64);
        _callAndLog("refundNonce(bytes32)", REFUND_NONCE_SELECTOR, channelId, 32);
    }

    function _callAndLog(
        string memory signature,
        bytes4 selector,
        bytes32 channelId,
        uint256 expectedLen
    ) internal view {
        (bool ok, bytes memory raw) = settlementStatic(selector, channelId);
        console2.log("");
        console2.log(signature);
        console2.log("selector", vm.toString(bytes32(selector)));
        console2.log("calldata", vm.toString(abi.encodePacked(selector, channelId)));
        console2.log("success", ok);
        console2.log("raw return", vm.toString(raw));
        require(ok, string.concat("VerifyReadAbi: call failed for ", signature));
        require(raw.length >= expectedLen, string.concat("VerifyReadAbi: short return for ", signature));

        if (expectedLen == 64) {
            uint256 word0 = uint256(bytes32(_slice32(raw, 0)));
            uint256 word1 = uint256(bytes32(_slice32(raw, 32)));
            console2.log("word0", word0);
            console2.log("word1", word1);
        } else {
            console2.log("word0", uint256(bytes32(_slice32(raw, 0))));
        }
    }

    function settlementStatic(
        bytes4 selector,
        bytes32 channelId
    ) internal view returns (bool ok, bytes memory raw) {
        address settlement = vm.envOr("X402_BATCH_SETTLEMENT", DEFAULT_SETTLEMENT);
        return settlement.staticcall(abi.encodeWithSelector(selector, channelId));
    }

    function _slice32(bytes memory raw, uint256 offset) internal pure returns (bytes32 word) {
        assembly {
            word := mload(add(add(raw, 0x20), offset))
        }
    }
}

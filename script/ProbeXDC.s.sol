// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

import {x402BatchSettlement} from "../src/x402BatchSettlement.sol";
import {ERC3009DepositCollector} from "../src/periphery/ERC3009DepositCollector.sol";
import {Permit2DepositCollector} from "../src/periphery/Permit2DepositCollector.sol";

/// @title ProbeXDC
/// @notice Read-only XDC environment probe: EIP-1153, CREATE2 factory, Permit2, expected addresses.
///
///      forge script script/ProbeXDC.s.sol --rpc-url $XDC_APOTHEM_RPC_URL
///      forge script script/ProbeXDC.s.sol --rpc-url $XDC_RPC_URL
contract ProbeXDC is Script {
    address internal constant CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    address internal constant CANONICAL_PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    bytes32 internal constant BATCH_SALT = 0x000000000000000000000000000000000000000000000000e000000005be885c;
    bytes32 internal constant ERC3009_SALT = 0x0000000000000000000000000000000000000000000000001800000007a95284;
    bytes32 internal constant PERMIT2_COLLECTOR_SALT = 0x000000000000000000000000000000000000000000000000f800000001a5d4ff;

    /// @dev Same TSTORE/TLOAD program documented in docs/xdc-opcode-probe.md.
    string internal constant TSTORE_TLOAD_INITCODE = "0x600060005d60005c60005260206000f3";

    function run() public {
        console2.log("============================================================");
        console2.log("  XDC x402 batch-settlement environment probe");
        console2.log("============================================================");
        console2.log("chainId", block.chainid);
        console2.log("CREATE2 deployer", CREATE2_DEPLOYER);
        console2.log("CREATE2 code size", CREATE2_DEPLOYER.code.length);
        console2.log("Permit2", CANONICAL_PERMIT2);
        console2.log("Permit2 code size", CANONICAL_PERMIT2.code.length);

        _probeEip1153();
        _logExpectedAddresses();
    }

    function _probeEip1153() internal {
        string memory params = string.concat(
            '[{"from":"0x0000000000000000000000000000000000000000","data":"', TSTORE_TLOAD_INITCODE, '"},"latest"]'
        );
        bytes memory raw = vm.rpc("eth_call", params);
        console2.log("EIP-1153 eth_call bytes", raw.length);
        console2.log("EIP-1153 eth_call hex", vm.toString(raw));
        if (raw.length > 0) {
            console2.log("EIP-1153 eth_call utf8", string(raw));
        }
    }

    function _logExpectedAddresses() internal view {
        bytes memory batchInit = type(x402BatchSettlement).creationCode;
        bytes32 batchHash = keccak256(batchInit);
        address settlement = _computeCreate2Addr(BATCH_SALT, batchHash, CREATE2_DEPLOYER);

        bytes memory ercInit = abi.encodePacked(type(ERC3009DepositCollector).creationCode, abi.encode(settlement));
        address erc3009 = _computeCreate2Addr(ERC3009_SALT, keccak256(ercInit), CREATE2_DEPLOYER);

        bytes memory permit2Init =
            abi.encodePacked(type(Permit2DepositCollector).creationCode, abi.encode(settlement, CANONICAL_PERMIT2));
        address permit2Collector = _computeCreate2Addr(PERMIT2_COLLECTOR_SALT, keccak256(permit2Init), CREATE2_DEPLOYER);

        console2.log("");
        console2.log("Expected CREATE2 addresses (official salts)");
        console2.log("x402BatchSettlement", settlement);
        console2.log("  initCodeHash", vm.toString(batchHash));
        console2.log("  deployed", settlement.code.length > 0);
        console2.log("ERC3009DepositCollector", erc3009);
        console2.log("  deployed", erc3009.code.length > 0);
        console2.log("Permit2DepositCollector", permit2Collector);
        console2.log("  deployed", permit2Collector.code.length > 0);
    }

    function _computeCreate2Addr(
        bytes32 salt,
        bytes32 initCodeHash,
        address deployer
    ) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, initCodeHash)))));
    }
}

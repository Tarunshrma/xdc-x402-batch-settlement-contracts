// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

import {DeployBatchSettlement} from "./DeployBatchSettlement.s.sol";

/// @title DeployXDC
/// @notice XDC chain-id / preflight wrapper around the unmodified official CREATE2 deploy script.
/// @dev Local to this repository. Official salts, factory, and initCode come from
///      `DeployBatchSettlement.s.sol` (copied from x402-foundation/x402).
///
///      Prefer Apothem (chain id 51) until the operator explicitly chooses XDC
///      mainnet (chain id 50).
///
///      forge script script/DeployXDC.s.sol --rpc-url $XDC_APOTHEM_RPC_URL --broadcast
contract DeployXDC is Script {
    uint256 internal constant XDC_MAINNET = 50;
    uint256 internal constant XDC_APOTHEM = 51;

    address internal constant CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    address internal constant CANONICAL_PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    function run() public {
        require(
            block.chainid == XDC_MAINNET || block.chainid == XDC_APOTHEM,
            "DeployXDC: chain must be XDC mainnet (50) or Apothem (51)"
        );
        require(CREATE2_DEPLOYER.code.length > 0, "DeployXDC: Arachnid CREATE2 deployer missing");
        require(CANONICAL_PERMIT2.code.length > 0, "DeployXDC: canonical Permit2 missing");

        console2.log("XDC preflight ok");
        console2.log("chainId", block.chainid);
        console2.log("CREATE2 deployer", CREATE2_DEPLOYER);
        console2.log("Permit2", CANONICAL_PERMIT2);

        OfficialBatchDeploy officialDeploy = new OfficialBatchDeploy();
        officialDeploy.run();
    }
}

/// @dev Inherits the official `run()` without overriding it.
contract OfficialBatchDeploy is DeployBatchSettlement {}

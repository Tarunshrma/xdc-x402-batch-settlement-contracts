// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IDepositCollector} from "../../src/interfaces/IDepositCollector.sol";

/// @title TransferFromCollector
/// @notice Test-only collector: `transferFrom(payer, settlement, amount)`.
/// @dev Not an official x402 collector. Do not deploy for production escrow.
contract TransferFromCollector is IDepositCollector {
    function collect(
        address payer,
        address token,
        uint256 amount,
        bytes32,
        bytes calldata
    ) external {
        bool ok = IERC20(token).transferFrom(payer, msg.sender, amount);
        require(ok, "TransferFromCollector: transferFrom failed");
    }
}

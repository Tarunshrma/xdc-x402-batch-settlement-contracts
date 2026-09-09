// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {x402BatchSettlement} from "../src/x402BatchSettlement.sol";
import {ERC3009DepositCollector} from "../src/periphery/ERC3009DepositCollector.sol";
import {Permit2DepositCollector} from "../src/periphery/Permit2DepositCollector.sol";
import {MockERC20} from "./helpers/MockERC20.sol";
import {TransferFromCollector} from "./helpers/TransferFromCollector.sol";

contract ReadAbiProofTest is Test {
    bytes4 internal constant CHANNELS_SELECTOR = 0x7a7ebd7b;
    bytes4 internal constant PENDING_WITHDRAWALS_SELECTOR = 0xb7f06ebe;
    bytes4 internal constant REFUND_NONCE_SELECTOR = 0xf0dc792e;

    x402BatchSettlement internal settlement;
    MockERC20 internal token;
    TransferFromCollector internal collector;

    uint256 internal payerPk = 0xA11CE;
    address internal payer;
    address internal receiver = address(0xB0B);
    address internal receiverAuthorizer = address(0xA17);

    function setUp() public {
        payer = vm.addr(payerPk);
        settlement = new x402BatchSettlement();
        token = new MockERC20();
        collector = new TransferFromCollector();
        token.mint(payer, 1_000_000);
        vm.prank(payer);
        token.approve(address(collector), type(uint256).max);
    }

    function testSelectorsMatchFacilitatorPR101() public pure {
        assertEq(bytes4(keccak256("channels(bytes32)")), CHANNELS_SELECTOR);
        assertEq(bytes4(keccak256("pendingWithdrawals(bytes32)")), PENDING_WITHDRAWALS_SELECTOR);
        assertEq(bytes4(keccak256("refundNonce(bytes32)")), REFUND_NONCE_SELECTOR);
    }

    function testEmptyChannelEncodingMatchesFacilitatorAssumptions() public view {
        bytes32 channelId = bytes32(0);

        (bool okCh, bytes memory rawCh) =
            address(settlement).staticcall(abi.encodeWithSelector(CHANNELS_SELECTOR, channelId));
        assertTrue(okCh);
        assertEq(rawCh.length, 64);
        assertEq(uint256(bytes32(_word(rawCh, 0))), 0, "channels word0 balance");
        assertEq(uint256(bytes32(_word(rawCh, 32))), 0, "channels word1 totalClaimed");

        (bool okW, bytes memory rawW) =
            address(settlement).staticcall(abi.encodeWithSelector(PENDING_WITHDRAWALS_SELECTOR, channelId));
        assertTrue(okW);
        assertEq(rawW.length, 64);
        assertEq(uint256(bytes32(_word(rawW, 0))), 0, "pendingWithdrawals word0 amount");
        assertEq(uint256(bytes32(_word(rawW, 32))), 0, "pendingWithdrawals word1 initiatedAt");

        (bool okN, bytes memory rawN) =
            address(settlement).staticcall(abi.encodeWithSelector(REFUND_NONCE_SELECTOR, channelId));
        assertTrue(okN);
        assertEq(rawN.length, 32);
        assertEq(uint256(bytes32(_word(rawN, 0))), 0, "refundNonce uint256");
    }

    function testTinyLifecycleClaimSettleAndReadShapes() public {
        x402BatchSettlement.ChannelConfig memory config = x402BatchSettlement.ChannelConfig({
            payer: payer,
            payerAuthorizer: address(0),
            receiver: receiver,
            receiverAuthorizer: receiverAuthorizer,
            token: address(token),
            withdrawDelay: 15 minutes,
            salt: bytes32(uint256(1))
        });

        vm.prank(payer);
        settlement.deposit(config, 100, address(collector), "");

        bytes32 channelId = settlement.getChannelId(config);
        {
            (uint128 balanceAfterDeposit, uint128 claimedAfterDeposit) = settlement.channels(channelId);
            assertEq(balanceAfterDeposit, 100);
            assertEq(claimedAfterDeposit, 0);
        }

        bytes32 digest = settlement.getVoucherDigest(channelId, 40);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(payerPk, digest);

        x402BatchSettlement.VoucherClaim[] memory claims = new x402BatchSettlement.VoucherClaim[](1);
        claims[0] = x402BatchSettlement.VoucherClaim({
            voucher: x402BatchSettlement.Voucher({channel: config, maxClaimableAmount: 40}),
            signature: abi.encodePacked(r, s, v),
            totalClaimed: 40
        });

        vm.prank(receiver);
        settlement.claim(claims);

        {
            (uint128 balanceAfterClaim, uint128 claimedAfterClaim) = settlement.channels(channelId);
            assertEq(balanceAfterClaim, 100);
            assertEq(claimedAfterClaim, 40);
        }

        uint256 receiverBefore = token.balanceOf(receiver);
        settlement.settle(receiver, address(token));
        assertEq(token.balanceOf(receiver), receiverBefore + 40);

        {
            (uint128 withdrawAmount, uint40 initiatedAt) = settlement.pendingWithdrawals(channelId);
            assertEq(withdrawAmount, 0);
            assertEq(initiatedAt, 0);
            assertEq(settlement.refundNonce(channelId), 0);
        }

        (, bytes memory rawCh) =
            address(settlement).staticcall(abi.encodeWithSelector(CHANNELS_SELECTOR, channelId));
        assertEq(uint256(bytes32(_word(rawCh, 0))), 100, "live channels word0");
        assertEq(uint256(bytes32(_word(rawCh, 32))), 40, "live channels word1");
    }

    function testOfficialCreate2SaltsHashAgainstExpectedCanonicalAddresses() public pure {
        address create2 = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
        bytes32 batchSalt = 0x000000000000000000000000000000000000000000000000e000000005be885c;
        bytes32 ercSalt = 0x0000000000000000000000000000000000000000000000001800000007a95284;
        bytes32 p2Salt = 0x000000000000000000000000000000000000000000000000f800000001a5d4ff;
        address permit2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

        address settlementAddr = _create2(create2, batchSalt, keccak256(type(x402BatchSettlement).creationCode));
        assertEq(settlementAddr, 0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003);

        bytes memory ercInit =
            abi.encodePacked(type(ERC3009DepositCollector).creationCode, abi.encode(settlementAddr));
        address ercAddr = _create2(create2, ercSalt, keccak256(ercInit));
        assertEq(ercAddr, 0x4020806089470a89826cB9fB1f4059150b550004);

        bytes memory pInit =
            abi.encodePacked(type(Permit2DepositCollector).creationCode, abi.encode(settlementAddr, permit2));
        address pAddr = _create2(create2, p2Salt, keccak256(pInit));
        assertEq(pAddr, 0x4020425FAf3B746C082C2f942b4E5159887B0005);
    }

    function _create2(address deployer, bytes32 salt, bytes32 initCodeHash) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, initCodeHash)))));
    }

    function _word(bytes memory raw, uint256 offset) internal pure returns (bytes32 word) {
        assembly {
            word := mload(add(add(raw, 0x20), offset))
        }
    }
}

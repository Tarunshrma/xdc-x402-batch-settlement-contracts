# Read ABI proof

The facilitator (`xdc-x402-facilitator` PR #101) fail-closed reader assumes
the official `x402BatchSettlement` public getters below. This document
compares those assumptions to unmodified source and to a local Foundry proof.

Live XDC `eth_call` against a deployed contract is **blocked until CREATE2
deployment** (see `docs/deployment-record.md`). After deploy, run
`script/VerifyReadAbi.s.sol` and paste the raw bytes here.

## Verdict

Facilitator PR #101 assumptions **match** the official ABI and source layout.
No facilitator workaround is required from this repo.

`refundNonce(bytes32)` is proven from source and local calls. The current
facilitator channel reader does not `eth_call` `refundNonce` yet (it only
appears on the batch payload). The getter is still recorded here.

## Selectors

| Method | Selector |
| --- | --- |
| `channels(bytes32)` | `0x7a7ebd7b` |
| `pendingWithdrawals(bytes32)` | `0xb7f06ebe` |
| `refundNonce(bytes32)` | `0xf0dc792e` |

Confirmed in `test/ReadAbiProof.t.sol` and against the facilitator Go
selectors in `internal/evm/batch_channel.go`.

## `channels(bytes32)`

Source:

```solidity
struct ChannelState {
    uint128 balance;
    uint128 totalClaimed;
}
mapping(bytes32 channelId => ChannelState) public channels;
```

Public getter ABI: `(uint128 balance, uint128 totalClaimed)` → two 32-byte
words.

| Word | Field | Facilitator PR #101 |
| --- | --- | --- |
| 0 (`out[0:32]`) | `balance` | expected word 0 = balance |
| 1 (`out[32:64]`) | `totalClaimed` | expected word 1 = totalClaimed |

**Result: confirmed.**

### Empty channel (local proof)

Sample `channelId`:

```text
0x0000000000000000000000000000000000000000000000000000000000000000
```

Calldata:

```text
0x7a7ebd7b0000000000000000000000000000000000000000000000000000000000000000
```

Raw return (local `eth_call` equivalent via `staticcall` on a fresh deploy):

```text
0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
```

Decoded: `balance = 0`, `totalClaimed = 0`.

After a tiny local lifecycle (deposit 100, claim 40) the same getter returned
word0 = 100, word1 = 40.

## `pendingWithdrawals(bytes32)`

Source:

```solidity
struct WithdrawalState {
    uint128 amount;
    uint40 initiatedAt; // timestamp; zero if none pending
}
mapping(bytes32 channelId => WithdrawalState) public pendingWithdrawals;
```

Public getter ABI: `(uint128 amount, uint40 initiatedAt)` → two 32-byte words.

| Word | Official field | Facilitator field |
| --- | --- | --- |
| 0 (`out[0:32]`) | `amount` | unused by PR #101 reader |
| 1 (`out[32:64]`) | `initiatedAt` | `WithdrawRequestedAt` |

PR #101 reads **word 1** as the pending-withdraw timestamp. That is the
`initiatedAt` location in the official ABI.

The JSON/source name is `initiatedAt`, not `withdrawRequestedAt`. Layout is
what the reader uses; no facilitator fix is required for decoding. A later
rename in facilitator comments/types would be cosmetic only.

### Empty channel (local proof)

Calldata:

```text
0xb7f06ebe0000000000000000000000000000000000000000000000000000000000000000
```

Raw return:

```text
0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
```

Decoded: `amount = 0`, `initiatedAt = 0` (no pending withdrawal).

## `refundNonce(bytes32)`

Source:

```solidity
mapping(bytes32 channelId => uint256) public refundNonce;
```

Public getter ABI: `uint256`.

| Word | Field | Facilitator PR #101 |
| --- | --- | --- |
| 0 | `uint256` nonce | expected uint256 |

**Result: confirmed.**

### Empty channel (local proof)

Calldata:

```text
0xf0dc792e0000000000000000000000000000000000000000000000000000000000000000
```

Raw return:

```text
0x0000000000000000000000000000000000000000000000000000000000000000
```

Decoded: `0`.

## Live XDC capture (to fill after deploy)

| Item | Value |
| --- | --- |
| Network / chain id | _pending_ |
| Settlement address | _pending_ |
| Sample channelId | _pending_ |
| `channels` raw | _pending_ |
| `pendingWithdrawals` raw | _pending_ |
| `refundNonce` raw | _pending_ |

Command:

```bash
forge script script/VerifyReadAbi.s.sol --rpc-url "$XDC_APOTHEM_RPC_URL"
```

## Facilitator follow-up

None for ABI layout. Do not change facilitator behavior in this repo.

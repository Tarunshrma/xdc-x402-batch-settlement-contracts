# xdc-x402-batch-settlement-contracts

This repository deploys the official x402 batch-settlement EVM contracts to
XDC for compatibility testing and public verification.

It is a standalone proof/deployment repo for the XDC facilitator. It does
not change facilitator behavior.

## Disclaimer

This is an **independent** XDC deployment and compatibility-proof project.
It is **not** an official product of the x402 Foundation, Coinbase, Base, or
the XDC Network, and it does not imply their endorsement unless they
explicitly approve it.

This is **not** a production custody recommendation. The batch-settlement
contract holds escrowed funds. Use tiny test amounts only until source
verification, ABI proof, and a production review are complete. See
[docs/audit-and-risk-notes.md](docs/audit-and-risk-notes.md).

## Upstream pin

| Item | Value |
| --- | --- |
| Upstream | https://github.com/x402-foundation/x402 |
| Commit | [`84ffb6412a1f2f45a62971c5549eff794281c099`](https://github.com/x402-foundation/x402/commit/84ffb6412a1f2f45a62971c5549eff794281c099) |
| License | Apache-2.0 (repo); copied Solidity retains MIT SPDX |
| Attribution | [NOTICE](NOTICE), [docs/provenance.md](docs/provenance.md) |

Official sources are copied **verbatim**. Layout matches upstream
`contracts/evm/src/` so imports stay untouched.

Specs:

- https://github.com/x402-foundation/x402/blob/84ffb6412a1f2f45a62971c5549eff794281c099/specs/schemes/batch-settlement/scheme_batch_settlement_evm.md
- https://github.com/x402-foundation/x402/blob/84ffb6412a1f2f45a62971c5549eff794281c099/specs/schemes/batch-settlement/scheme_batch_settlement.md

## Facilitator

XDC facilitator (batch-settlement reader PR sequence, including PR #101):
https://github.com/Tarunshrma/xdc-x402-facilitator

## Deployed XDC addresses

Live CREATE2 deploy on **XDC Network (chain id 50)** on 2026-09-09 from
`0xaf28621e287e4EA0F14FA7e7ba365206FD6279DA`. Official salts produced the
canonical addresses:

| Contract | Address | Explorer | Deploy tx |
| --- | --- | --- | --- |
| `x402BatchSettlement` | `0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003` | [xdcscan](https://xdcscan.com/address/0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003) | [0x27507da7…](https://xdcscan.com/tx/0x27507da722c2007d40c70ee98e8ef6e337ebf03a5c34bccb415eb27b7a2cfb63) |
| `ERC3009DepositCollector` | `0x4020806089470a89826cB9fB1f4059150b550004` | [xdcscan](https://xdcscan.com/address/0x4020806089470a89826cB9fB1f4059150b550004) | [0xe58f5ff9…](https://xdcscan.com/tx/0xe58f5ff94fab0d698a80b1e3a9a7a7d1d9d0e82f494a3392c6ff0ea8b8ba8305) |
| `Permit2DepositCollector` | `0x4020425FAf3B746C082C2f942b4E5159887B0005` | [xdcscan](https://xdcscan.com/address/0x4020425FAf3B746C082C2f942b4E5159887B0005) | [0xd29f142f…](https://xdcscan.com/tx/0xd29f142fe1704154bc543bd16e9a7dd98004bc869dc24cfe1bec10a445dd4523) |

| Item | Value |
| --- | --- |
| RPC host | `rpcxdcai.icotokens.net` |
| CREATE2 factory | `0x4e59b44847b379578588920cA78FbF26c0B4956C` |
| Blocks | 107026531, 107026532, 107026534 |
| Gas used | 3,101,478 / 369,263 / 724,394 |
| Compiler | solc 0.8.28, cancun, optimizer 200, `cbor_metadata = false` |
| Source verification | pending on XDC explorer |

Empty-channel `eth_call` against the live settlement contract matches
facilitator PR #101: `channels` and `pendingWithdrawals` return two zero
words; `refundNonce` returns one zero word.

## Opcode probe

EIP-1153 `TSTORE`/`TLOAD` `eth_call` succeeded on XDC mainnet and Apothem
(`result = 0x00…00`). See [docs/xdc-opcode-probe.md](docs/xdc-opcode-probe.md).

## Read ABI proof

Local Foundry tests confirm facilitator PR #101 word layout:

- `channels(bytes32)` word 0 = `balance`, word 1 = `totalClaimed`
- `pendingWithdrawals(bytes32)` word 1 = `initiatedAt` (facilitator:
  `WithdrawRequestedAt`)
- `refundNonce(bytes32)` returns `uint256`

Details: [docs/read-abi-proof.md](docs/read-abi-proof.md).

Live XDC mainnet empty-channel calldata/returns:

- `channels(bytes32)` `0x7a7ebd7b` → 64 zero bytes (word0 balance, word1 totalClaimed)
- `pendingWithdrawals(bytes32)` `0xb7f06ebe` → 64 zero bytes (word1 = `initiatedAt`)
- `refundNonce(bytes32)` `0xf0dc792e` → 32 zero bytes

## Build

Requires [Foundry](https://book.getfoundry.sh/getting-started/installation).

```bash
git submodule update --init --recursive
# or: forge install
forge build
forge test -vvv
```

Compiler settings match upstream `contracts/evm/foundry.toml` at the pinned
commit (`solc 0.8.28`, Cancun, optimizer 200, no CBOR metadata).

## Probe and deploy

```bash
cp .env.example .env
# set PRIVATE_KEY only on the operator machine; never commit it

forge script script/ProbeXDC.s.sol --rpc-url "$XDC_APOTHEM_RPC_URL"
# after preflight, operator broadcast:
forge script script/DeployXDC.s.sol --rpc-url "$XDC_APOTHEM_RPC_URL" --broadcast
forge script script/VerifyReadAbi.s.sol --rpc-url "$XDC_APOTHEM_RPC_URL"
```

`script/DeployBatchSettlement.s.sol` is the unmodified official CREATE2
script. `DeployXDC.s.sol` only gates chain id 50/51 and then runs that
script.

## Documentation

- [docs/provenance.md](docs/provenance.md)
- [docs/xdc-opcode-probe.md](docs/xdc-opcode-probe.md)
- [docs/deployment-record.md](docs/deployment-record.md)
- [docs/read-abi-proof.md](docs/read-abi-proof.md)
- [docs/audit-and-risk-notes.md](docs/audit-and-risk-notes.md)
- [docs/upstream/x402-batch-settlement-implementers.md](docs/upstream/x402-batch-settlement-implementers.md)

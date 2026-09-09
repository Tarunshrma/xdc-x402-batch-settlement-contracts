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

Not yet broadcast from this repo. Preflight on 2026-09-09 found CREATE2 and
Permit2 already on XDC mainnet (50) and Apothem (51); canonical
`x402BatchSettlement` had no code yet.

If the official CREATE2 path succeeds, expected addresses are:

| Contract | Address |
| --- | --- |
| `x402BatchSettlement` | `0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003` |
| `ERC3009DepositCollector` | `0x4020806089470a89826cB9fB1f4059150b550004` |
| `Permit2DepositCollector` | `0x4020425FAf3B746C082C2f942b4E5159887B0005` |

This repo's compile at the pinned settings produces those CREATE2
addresses. They are **not yet deployed** on XDC mainnet or Apothem.
Fill explorer links in [docs/deployment-record.md](docs/deployment-record.md)
after the operator broadcasts and verifies.

## Opcode probe

EIP-1153 `TSTORE`/`TLOAD` `eth_call` succeeded on XDC mainnet and Apothem
(`result = 0x00…00`). See [docs/xdc-opcode-probe.md](docs/xdc-opcode-probe.md).

That is a positive runtime signal, not a substitute for a live deploy.

## Read ABI proof

Local Foundry tests confirm facilitator PR #101 word layout:

- `channels(bytes32)` word 0 = `balance`, word 1 = `totalClaimed`
- `pendingWithdrawals(bytes32)` word 1 = `initiatedAt` (facilitator:
  `WithdrawRequestedAt`)
- `refundNonce(bytes32)` returns `uint256`

Details: [docs/read-abi-proof.md](docs/read-abi-proof.md).

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

# Provenance

## Upstream repository

https://github.com/x402-foundation/x402

## Upstream commit SHA

```text
84ffb6412a1f2f45a62971c5549eff794281c099
```

Commit message: `feat: x402BatchSettlement contract (#1950)`

Browse the commit: https://github.com/x402-foundation/x402/commit/84ffb6412a1f2f45a62971c5549eff794281c099

This is the known official contract introduction commit. Git history for
`contracts/evm/src/x402BatchSettlement.sol` at the time this repo was created
had that single commit.

## How files are included

Copied **verbatim**. Not a git submodule of the full x402 tree.

Relative paths under `src/` match upstream `contracts/evm/src/` so official
imports stay untouched.

### Copied (unmodified)

| This repo | Upstream path at pinned commit |
| --- | --- |
| `src/x402BatchSettlement.sol` | `contracts/evm/src/x402BatchSettlement.sol` |
| `src/interfaces/IDepositCollector.sol` | `contracts/evm/src/interfaces/IDepositCollector.sol` |
| `src/interfaces/IERC3009.sol` | `contracts/evm/src/interfaces/IERC3009.sol` |
| `src/interfaces/ISignatureTransfer.sol` | `contracts/evm/src/interfaces/ISignatureTransfer.sol` |
| `src/periphery/DepositCollector.sol` | `contracts/evm/src/periphery/DepositCollector.sol` |
| `src/periphery/ERC3009DepositCollector.sol` | `contracts/evm/src/periphery/ERC3009DepositCollector.sol` |
| `src/periphery/Permit2DepositCollector.sol` | `contracts/evm/src/periphery/Permit2DepositCollector.sol` |
| `script/DeployBatchSettlement.s.sol` | `contracts/evm/script/DeployBatchSettlement.s.sol` |
| `docs/upstream/x402-batch-settlement-implementers.md` | `contracts/evm/docs/x402-batch-settlement-implementers.md` |
| `LICENSE` | `LICENSE` |

SHA-256 of the copied files at import time:

```text
42ef0aac79f45d66a1f842d280dcaee69900e7d71b4d79add6cddf65ca220b98  src/x402BatchSettlement.sol
01a18a728c0bb9a814e7287a57fe597b755bfe2e6478f9eb1c70a05489656925  src/interfaces/IDepositCollector.sol
1102aa62bb5996566924935533e3f86cbce57421a49375fba7886e3613f9c261  src/interfaces/IERC3009.sol
9ba755409cba5cada98715cc09c9efa50014d6f4c1e98da43e18bc301fe9bbc4  src/interfaces/ISignatureTransfer.sol
ffe8845cd62d535ff44b564db2b11f7d9cd22e6212cda6089fcd55f41c5464e6  src/periphery/DepositCollector.sol
710174a26c58a27e8280f41bc41d3645317e9ddafaaa3fd873ba013103cfe1d7  src/periphery/ERC3009DepositCollector.sol
0c37cb257a55668c001c96f56ca89d3870d1a952a75f427b01dd9592b048fd77  src/periphery/Permit2DepositCollector.sol
0ca554c58f0398da25d767f7752dc8b205f9737bc1c0be938b1e2c0228c6bcbc  script/DeployBatchSettlement.s.sol
1f500507cb9ed6112ef1477603a9b5042a1bfd0d110ad7b374e9d81ec80df36a  docs/upstream/x402-batch-settlement-implementers.md
50e6751797c50dedd75ef1b8a0d9e42f5f8472e9fbce91f34718e9f97b0c780a  LICENSE
```

### Not copied

Permit2 proxy contracts (`x402ExactPermit2Proxy`, `x402UptoPermit2Proxy`),
vanity-miner, and upstream unit tests are out of scope for this XDC
batch-settlement proof repo.

Audit PDFs are **not** copied. Redistribution permission for those reports is
not assumed. Link to upstream instead.

## Whether source is modified

Official Solidity listed above is **not modified**. Exact diff from upstream:
none.

Local-only files (not from upstream):

- `script/DeployXDC.s.sol`
- `script/ProbeXDC.s.sol`
- `script/VerifyReadAbi.s.sol`
- `test/**`
- `docs/*.md` except `docs/upstream/`
- `foundry.toml`, `remappings.txt`, `README.md`, `NOTICE`, `.github/**`

`foundry.toml` copies the official compiler settings that control bytecode
(`solc 0.8.28`, `cancun`, optimizer 200, `via_ir = false`,
`cbor_metadata = false`, `bytecode_hash = "none"`) and adds XDC RPC endpoint
names. RPC URLs are supplied via environment variables.

## Pinned Foundry libraries

These match `x402-foundation/x402` gitlinks at the pinned commit
(`contracts/evm/lib`). `foundry.lock` records the same SHAs.

| Library | Git SHA | Notes |
| --- | --- | --- |
| [foundry-rs/forge-std](https://github.com/foundry-rs/forge-std) | `1801b0541f4fda118a10798fd3486bb7051c5dd6` | test/script stdlib |
| [OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) | `fcbae5394ae8ad52d8e580a3477db99814b9d565` | v5.5.0 (`ReentrancyGuardTransient`) |
| [Uniswap/permit2](https://github.com/Uniswap/permit2) | `cc56ad0f3439c502c246fc5cfcc3db92bb8b7219` | pinned for fidelity; batch collectors use local `ISignatureTransfer` |

## Upstream license

Verified from the pinned commit:

- Repository `LICENSE`: **Apache License 2.0**
- Repository `NOTICE`: Apache-2.0, Copyright 2024 Coinbase
- Copied Solidity files: `SPDX-License-Identifier: MIT` (preserved)

## Repo license

This repository uses **Apache-2.0** (`LICENSE`), matching upstream. See
`NOTICE` for attribution of copied material and the local addendum.

SPDX headers in copied Solidity files were not rewritten.

## Audit reports (linked, not vendored)

Upstream path: https://github.com/x402-foundation/x402/tree/84ffb6412a1f2f45a62971c5549eff794281c099/contracts/evm/audits

- https://github.com/x402-foundation/x402/blob/84ffb6412a1f2f45a62971c5549eff794281c099/contracts/evm/audits/cantina_x402_feb2026.pdf
- https://github.com/x402-foundation/x402/blob/84ffb6412a1f2f45a62971c5549eff794281c099/contracts/evm/audits/cantina_x402_mar2026.pdf
- https://github.com/x402-foundation/x402/blob/84ffb6412a1f2f45a62971c5549eff794281c099/contracts/evm/audits/cantina_x402_may2026.pdf

See `docs/audit-and-risk-notes.md`.

## Specs (linked, not vendored)

- https://github.com/x402-foundation/x402/blob/84ffb6412a1f2f45a62971c5549eff794281c099/specs/schemes/batch-settlement/scheme_batch_settlement_evm.md
- https://github.com/x402-foundation/x402/blob/84ffb6412a1f2f45a62971c5549eff794281c099/specs/schemes/batch-settlement/scheme_batch_settlement.md

## Third-party notices

OpenZeppelin Contracts are MIT-licensed and pulled as a Foundry library, not
re-copied into `src/`. Uniswap Permit2 is MIT-licensed and pinned the same
way. Arachnid's CREATE2 deployer and canonical Permit2 are referenced by
address only.

This repository does not claim endorsement by the x402 Foundation, Coinbase,
Base, Uniswap, OpenZeppelin, or the XDC Network.

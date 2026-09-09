# Deployment record

Live CREATE2 broadcast has **not** been sent from this repository. This file
records what is proven, what is still blocked, and the fields to fill after
the operator deploys.

Prefer **Apothem (chain id 51)** first. Use XDC mainnet (chain id 50) only
when the operator explicitly chooses it and understands gas and custody
implications.

## Blocker (current)

No deployer private key or funded operator account is present in this
environment, and none will be committed. Preflight on public RPCs already
shows the CREATE2 path is available:

| Check | XDC mainnet (50) | Apothem (51) |
| --- | --- | --- |
| EIP-1153 TSTORE/TLOAD `eth_call` | pass (`0x00…00`) | pass (`0x00…00`) |
| Arachnid CREATE2 factory code | present | present |
| Canonical Permit2 code | present | present |
| `x402BatchSettlement` at canonical address | **not deployed** (`0x`) | **not deployed** (`0x`) |

To deploy (operator machine, never commit the key):

```bash
cp .env.example .env
# set PRIVATE_KEY and RPC URL for Apothem first

source .env
forge script script/ProbeXDC.s.sol --rpc-url "$XDC_APOTHEM_RPC_URL"
forge script script/DeployXDC.s.sol --rpc-url "$XDC_APOTHEM_RPC_URL" --broadcast
```

After broadcast, fill the tables below and run:

```bash
forge script script/VerifyReadAbi.s.sol --rpc-url "$XDC_APOTHEM_RPC_URL"
```

Then verify source on the XDC explorer and paste the links here.

## Target networks

| Field | Apothem (preferred first) | XDC mainnet |
| --- | --- | --- |
| Network name | XDC Apothem | XDC Network |
| Chain id | 51 | 50 |
| RPC URL host | `rpc.apothem.network` | `rpcxdcai.icotokens.net` |
| Explorer | https://testnet.xdcscan.com | https://xdcscan.com |

RPC secrets are not used. Only public hosts are listed.

## Expected CREATE2 parameters (official, unmodified)

These come from `script/DeployBatchSettlement.s.sol` at the pinned x402
commit. XDC will produce the canonical addresses **only if** this factory,
these salts, this bytecode, constructor args, and compiler settings match.

| Item | Value |
| --- | --- |
| CREATE2 factory | `0x4e59b44847b379578588920cA78FbF26c0B4956C` (Arachnid) |
| Compiler | `solc 0.8.28` |
| EVM version | `cancun` |
| Optimizer | enabled, 200 runs |
| `via_ir` | false |
| `cbor_metadata` | false |
| `bytecode_hash` | none |
| Permit2 (collector ctor) | `0x000000000022D473030F116dDEE9F6B43aC78BA3` |

| Contract | Salt | Constructor args | Canonical address |
| --- | --- | --- | --- |
| `x402BatchSettlement` | `0x…e000000005be885c` | none (EIP-712 name/version are constants) | `0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003` |
| `ERC3009DepositCollector` | `0x…1800000007a95284` | `settlement` | `0x4020806089470a89826cB9fB1f4059150b550004` |
| `Permit2DepositCollector` | `0x…f800000001a5d4ff` | `settlement`, Permit2 | `0x4020425FAf3B746C082C2f942b4E5159887B0005` |

Local compilation of the unmodified sources at the pinned compiler settings
reproduces those canonical addresses (`forge test --match-test testOfficialCreate2SaltsHashAgainstExpectedCanonicalAddresses`).

Recorded bytecode hashes from `forge inspect` in this repo (solc 0.8.28,
cancun, optimizer 200, `cbor_metadata = false`, `bytecode_hash = "none"`):

| Artifact | `cast keccak` |
| --- | --- |
| `x402BatchSettlement` creation bytecode | `0xed07c0a1aeb6bd4b8e28932959d66e9f2c1a2f6ebb1fd3dc5f3fbcf8135850f6` |
| `x402BatchSettlement` deployed bytecode | `0x5ff2eda5f092227f1b7d92dd6ad9fcc6ca644b7d2e254771dfc3e09abb3d7cb0` |
| `ERC3009DepositCollector` creation bytecode | `0xc3feb5fda17ac798ec246937560a910fc745d91a89832531a7b31b200bd1fdf2` |
| `Permit2DepositCollector` creation bytecode | `0xe1c6c6e25860594320f1ae87378f4df044290772cba477e0d64d154e1a03995b` |

`ProbeXDC.s.sol` against Apothem (51) and XDC mainnet (50) on 2026-09-09
computed the canonical CREATE2 addresses above and reported `deployed false`
for all three.

## Apothem deployment (to fill after broadcast)

| Field | Value |
| --- | --- |
| Network name | XDC Apothem |
| Chain id | 51 |
| RPC URL host | `rpc.apothem.network` |
| Deployer address | _pending operator broadcast_ |
| `x402BatchSettlement` | _pending_ |
| `ERC3009DepositCollector` | _pending_ |
| `Permit2DepositCollector` | _pending_ |
| Deployment tx hashes | _pending_ |
| Gas used | _pending_ |
| Bytecode hash | _pending (record `cast keccak $(forge inspect x402BatchSettlement deployedBytecode)` after compile)_ |
| Explorer source verification | _pending_ |

## XDC mainnet deployment (to fill only if operator chooses mainnet)

| Field | Value |
| --- | --- |
| Network name | XDC Network |
| Chain id | 50 |
| RPC URL host | `rpcxdcai.icotokens.net` |
| Deployer address | _not started_ |
| Deployed addresses | _not started_ |
| Deployment tx hashes | _not started_ |
| Explorer source verification | _not started_ |

## Verification notes

XDC explorer verification UIs differ from Etherscan. After deploy, submit
the same compiler settings as `foundry.toml` and the unmodified sources
under `src/`. Constructor args:

- `x402BatchSettlement`: none
- `ERC3009DepositCollector`: `abi.encode(settlementAddress)`
- `Permit2DepositCollector`: `abi.encode(settlementAddress, permit2Address)`

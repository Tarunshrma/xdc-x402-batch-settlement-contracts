# Deployment record

Live CREATE2 broadcast **completed on XDC mainnet (chain id 50)** on
2026-09-09. Apothem was not used for this deploy.

## Status

| Check | XDC mainnet (50) | Apothem (51) |
| --- | --- | --- |
| EIP-1153 TSTORE/TLOAD `eth_call` | pass (`0x00…00`) | pass (`0x00…00`) |
| Arachnid CREATE2 factory code | present | present |
| Canonical Permit2 code | present | present |
| `x402BatchSettlement` at canonical address | **deployed** | not deployed |

## Target networks

| Field | Apothem | XDC mainnet |
| --- | --- | --- |
| Network name | XDC Apothem | XDC Network |
| Chain id | 51 | 50 |
| RPC URL host | `rpc.apothem.network` | `rpcxdcai.icotokens.net` |
| Explorer | https://testnet.xdcscan.com | https://xdcscan.com |

RPC secrets are not used. Only public hosts are listed.

## Expected CREATE2 parameters (official, unmodified)

These come from `script/DeployBatchSettlement.s.sol` at the pinned x402
commit. XDC produced the canonical addresses because factory, salts,
bytecode, constructor args, and compiler settings matched.

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

Recorded bytecode hashes from `forge inspect` in this repo (solc 0.8.28,
cancun, optimizer 200, `cbor_metadata = false`, `bytecode_hash = "none"`):

| Artifact | `cast keccak` |
| --- | --- |
| `x402BatchSettlement` creation bytecode | `0xed07c0a1aeb6bd4b8e28932959d66e9f2c1a2f6ebb1fd3dc5f3fbcf8135850f6` |
| `x402BatchSettlement` deployed bytecode | `0x5ff2eda5f092227f1b7d92dd6ad9fcc6ca644b7d2e254771dfc3e09abb3d7cb0` |
| `ERC3009DepositCollector` creation bytecode | `0xc3feb5fda17ac798ec246937560a910fc745d91a89832531a7b31b200bd1fdf2` |
| `Permit2DepositCollector` creation bytecode | `0xe1c6c6e25860594320f1ae87378f4df044290772cba477e0d64d154e1a03995b` |

## XDC mainnet deployment

Broadcast via `forge script script/DeployXDC.s.sol:DeployXDC --broadcast --slow`.

| Field | Value |
| --- | --- |
| Network name | XDC Network |
| Chain id | 50 |
| RPC URL host | `rpcxdcai.icotokens.net` |
| Deployer address | `0xaf28621e287e4EA0F14FA7e7ba365206FD6279DA` |
| `x402BatchSettlement` | [`0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003`](https://xdcscan.com/address/0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003) |
| `ERC3009DepositCollector` | [`0x4020806089470a89826cB9fB1f4059150b550004`](https://xdcscan.com/address/0x4020806089470a89826cB9fB1f4059150b550004) |
| `Permit2DepositCollector` | [`0x4020425FAf3B746C082C2f942b4E5159887B0005`](https://xdcscan.com/address/0x4020425FAf3B746C082C2f942b4E5159887B0005) |
| Settlement tx | [`0x27507da722c2007d40c70ee98e8ef6e337ebf03a5c34bccb415eb27b7a2cfb63`](https://xdcscan.com/tx/0x27507da722c2007d40c70ee98e8ef6e337ebf03a5c34bccb415eb27b7a2cfb63) (block 107026531, gas 3,101,478) |
| ERC3009 collector tx | [`0xe58f5ff94fab0d698a80b1e3a9a7a7d1d9d0e82f494a3392c6ff0ea8b8ba8305`](https://xdcscan.com/tx/0xe58f5ff94fab0d698a80b1e3a9a7a7d1d9d0e82f494a3392c6ff0ea8b8ba8305) (block 107026532, gas 369,263) |
| Permit2 collector tx | [`0xd29f142fe1704154bc543bd16e9a7dd98004bc869dc24cfe1bec10a445dd4523`](https://xdcscan.com/tx/0xd29f142fe1704154bc543bd16e9a7dd98004bc869dc24cfe1bec10a445dd4523) (block 107026534, gas 724,394) |
| Bytecode hash | `x402BatchSettlement` deployed `0x5ff2eda5f092227f1b7d92dd6ad9fcc6ca644b7d2e254771dfc3e09abb3d7cb0` |
| Explorer source verification | pending |

## Apothem deployment

| Field | Value |
| --- | --- |
| Network name | XDC Apothem |
| Chain id | 51 |
| RPC URL host | `rpc.apothem.network` |
| Deployer address | not broadcast |
| Deployed addresses | not deployed |

## Verification notes

XDC explorer verification UIs differ from Etherscan. After deploy, submit
the same compiler settings as `foundry.toml` and the unmodified sources
under `src/`. Constructor args:

- `x402BatchSettlement`: none
- `ERC3009DepositCollector`: `abi.encode(settlementAddress)`
- `Permit2DepositCollector`: `abi.encode(settlementAddress, permit2Address)`

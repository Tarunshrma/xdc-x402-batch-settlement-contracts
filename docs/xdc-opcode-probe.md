# XDC opcode probe (EIP-1153)

`x402BatchSettlement` uses OpenZeppelin `ReentrancyGuardTransient`, which
requires EIP-1153 `TSTORE` / `TLOAD`. This document records the probe and how
to reproduce it.

## Result (recorded)

| Item | Value |
| --- | --- |
| Date | 2026-09-09 |
| RPC host | `rpcxdcai.icotokens.net` (XDC mainnet) |
| `eth_chainId` | `0x32` (50) |
| Call | `eth_call` with omitted `to`; `data` is the tiny TSTORE/TLOAD program |
| Result | `0x0000000000000000000000000000000000000000000000000000000000000000` |
| Status | Success |

Apothem testnet (`rpc.apothem.network`, chain id `0x33` / 51) returned the
same result on 2026-09-09.

A prior operator probe against the same mainnet RPC also succeeded. This
repo re-ran the call and got the expected zero word.

## Reproducer

```bash
curl https://rpcxdcai.icotokens.net/ \
  -H 'content-type: application/json' \
  --data '{
    "jsonrpc":"2.0",
    "id":1,
    "method":"eth_call",
    "params":[{
      "from":"0x0000000000000000000000000000000000000000",
      "data":"0x600060005d60005c60005260206000f3"
    },"latest"]
  }'
```

Apothem:

```bash
curl https://rpc.apothem.network/ \
  -H 'content-type: application/json' \
  --data '{
    "jsonrpc":"2.0",
    "id":1,
    "method":"eth_call",
    "params":[{
      "from":"0x0000000000000000000000000000000000000000",
      "data":"0x600060005d60005c60005260206000f3"
    },"latest"]
  }'
```

Expected result:

```text
result = 0x0000000000000000000000000000000000000000000000000000000000000000
```

Foundry wrapper (no broadcast):

```bash
forge script script/ProbeXDC.s.sol --rpc-url "$XDC_RPC_URL"
forge script script/ProbeXDC.s.sol --rpc-url "$XDC_APOTHEM_RPC_URL"
```

## Bytecode

`0x600060005d60005c60005260206000f3` is:

1. `PUSH1 0x00`
2. `PUSH1 0x00`
3. `TSTORE` (`0x5d`)
4. `PUSH1 0x00`
5. `TLOAD` (`0x5c`)
6. `PUSH1 0x00`
7. `MSTORE`
8. `PUSH1 0x20`
9. `PUSH1 0x00`
10. `RETURN`

The RPC executes this as a creation-style `eth_call` (`to` omitted). A
successful return of 32 zero bytes means `TSTORE`/`TLOAD` ran.

## Interpretation

The RPC executes a tiny TSTORE/TLOAD program successfully. This is a positive
runtime signal for EIP-1153 support, but final production confidence still
requires successful deployment and method calls on the reference contracts.

Companion checks on the same RPCs (2026-09-09):

- Arachnid CREATE2 deployer `0x4e59b44847b379578588920cA78FbF26c0B4956C` has code on mainnet and Apothem.
- Canonical Permit2 `0x000000000022D473030F116dDEE9F6B43aC78BA3` has code on mainnet and Apothem.
- Canonical `x402BatchSettlement` `0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003` had **no** code yet on either chain.

# Cursor Handoff: XDC x402 Batch-Settlement Contract Deployment Repo

## Task

Create a standalone public repository for deploying and verifying the official
x402 EVM batch-settlement contracts on XDC.

This is a dependency/blocker side project for the facilitator. Do not change
the facilitator behavior in this task.

## Recommended Repository Name

Preferred:

```text
xdc-x402-batch-settlement-contracts
```

Good alternatives:

```text
x402-batch-settlement-xdc
xdc-x402-contracts
xdc-batch-settlement-x402
```

Use the preferred name unless there is already a repo with that exact purpose.

## Why This Exists

The facilitator is adding support for x402 `batch-settlement` on EVM. The
software side can parse payloads, verify EIP-712 signatures, and read channel
state, but live batch support depends on one on-chain primitive:

```text
the x402BatchSettlement escrow contract and its deposit collectors must be
deployed, verified, and readable on XDC.
```

This project should prove that primitive independently, with enough public
evidence for:

- XDC community/protocol review
- explorer bytecode validation
- facilitator ABI integration
- later external audit review
- future official XDC announcement/post

## Current Context

Facilitator PR sequence already completed/in progress:

- PR #96: batch-settlement EVM MVP design.
- PR #97: disabled-by-default config + database schema.
- PR #98: `/supported` advertisement for batch-settlement.
- PR #99: batch payload parsing.
- PR #100: EIP-712/channel-id/signature verification.
- PR #101: fail-closed on-chain channel-state reader.

Operator has manually checked XDC RPC opcode compatibility with an EIP-1153
`TSTORE`/`TLOAD` probe, and the response was good.

That means the opcode gate appears promising, but this repo must still prove
real contract deployability and ABI compatibility.

## Official Sources

Use official x402 sources only.

Primary repo:

```text
https://github.com/x402-foundation/x402
```

Batch-settlement EVM spec:

```text
https://github.com/x402-foundation/x402/blob/main/specs/schemes/batch-settlement/scheme_batch_settlement_evm.md
```

Network-agnostic batch-settlement spec:

```text
https://github.com/x402-foundation/x402/blob/main/specs/schemes/batch-settlement/scheme_batch_settlement.md
```

Known official contract introduction commit from the x402 repo:

```text
84ffb64 - feat: x402BatchSettlement contract (#1950)
```

Important official paths from that commit/repo:

```text
contracts/evm/src/x402BatchSettlement.sol
contracts/evm/src/periphery/ERC3009DepositCollector.sol
contracts/evm/src/periphery/Permit2DepositCollector.sol
contracts/evm/script/DeployBatchSettlement.s.sol
contracts/evm/script/ComputeAddress.s.sol
contracts/evm/audits/
contracts/evm/docs/x402-batch-settlement-implementers.md
```

Canonical deployed addresses used by the official EVM stack on supported
chains:

```text
x402BatchSettlement       0x4020074e9dF2ce1deE5A9C1b5c3f541D02a10003
ERC3009DepositCollector   0x4020806089470a89826cB9fB1f4059150b550004
Permit2DepositCollector   0x4020425FAf3B746C082C2f942b4E5159887B0005
```

Do not assume XDC will produce the same addresses unless the same CREATE2
factory, salts, bytecode, constructor args, compiler settings, and deployment
path are confirmed.

## Desired Repo Shape

Create a minimal public repo that vendors or pins the official source clearly.

Suggested structure:

```text
README.md
LICENSE
NOTICE
foundry.toml
script/
  DeployXDC.s.sol
  ProbeXDC.s.sol
  VerifyReadAbi.s.sol
src/
  official/
    README.md
    x402BatchSettlement.sol
    periphery/
      ERC3009DepositCollector.sol
      Permit2DepositCollector.sol
docs/
  provenance.md
  xdc-opcode-probe.md
  deployment-record.md
  read-abi-proof.md
  audit-and-risk-notes.md
out/
  .gitkeep
```

If using a git submodule or subtree to pin `x402-foundation/x402`, document the
exact commit SHA. Prefer preserving upstream source untouched.

## Licensing Requirements

This repo is intended to be public and may copy or vendor upstream x402 contract
source. Treat licensing as a required gate before publishing.

Required steps:

1. Identify the upstream x402 repository license from the pinned source commit.
2. Preserve all upstream SPDX identifiers and copyright headers in copied files.
3. Do not remove or rewrite upstream notices from Solidity files, scripts, docs,
   or audit artifacts.
4. Add a root `LICENSE` file that is compatible with the upstream license.
5. Add a root `NOTICE` file if required by the upstream license or if it helps
   clearly attribute copied source/audit material.
6. In `docs/provenance.md`, state whether files are:
   - copied verbatim
   - included by submodule/subtree
   - generated from upstream artifacts
   - modified locally
7. If any upstream file is modified, document the exact modification and keep
   the original license notice intact.
8. Do not copy audit PDFs/reports into the repo unless their license/permission
   allows redistribution. If redistribution is unclear, link to the upstream
   audit path instead.
9. Do not use x402, Coinbase, Base, XDC, or any other third-party name/logo in a
   way that implies endorsement unless explicitly approved.
10. Include a disclaimer that this repo is an independent XDC deployment/proof
    project unless/until official endorsement exists.

Suggested default:

```text
Use the same open-source license as the upstream x402 repository if compatible
with the intended public deployment repo.
```

If the upstream license is Apache-2.0, include:

```text
LICENSE = Apache-2.0 text
NOTICE  = attribution to x402-foundation/x402, pinned commit, copied paths, and
          note that local deployment docs/scripts are maintained by this repo.
```

Do not guess the license. Verify it from the pinned upstream commit before
publishing.

## Non-Goals

Do not implement:

- custom escrow logic
- facilitator `/verify` changes
- facilitator `/settle` changes
- OpenZeppelin Relayer integration
- production environment changes
- modified token behavior
- admin upgradeability unless present in the official reference
- private-key material in the repo

## Required Documentation

### 1. Provenance

Create:

```text
docs/provenance.md
```

Record:

```text
upstream repository
upstream commit SHA
copied/submodule paths
whether source is modified
exact diff from upstream, if modified
upstream license
repo license
SPDX headers preserved
audit report paths copied/referenced
third-party notices
```

If any contract source is changed, make that obvious and treat it as a new
security review surface.

### 2. XDC Opcode Probe

Create:

```text
docs/xdc-opcode-probe.md
```

Record the already-successful manual probe and add reproducible instructions:

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

Expected result:

```text
result = 0x0000000000000000000000000000000000000000000000000000000000000000
```

Interpretation:

```text
The RPC executes a tiny TSTORE/TLOAD program successfully. This is a positive
runtime signal for EIP-1153 support, but final production confidence still
requires successful deployment and method calls on the reference contracts.
```

### 3. Deployment Record

Create:

```text
docs/deployment-record.md
```

Record:

```text
network name
chain id
RPC URL host only, not secrets
deployer address
deployed contract addresses
deployment tx hashes
gas used
compiler version
evm version / target
optimizer settings
constructor args
CREATE2 factory/salt details, if used
bytecode hash
source verification links on XDC explorer
```

Prefer testnet or a disposable deployment first. Use mainnet only when the
operator explicitly chooses it and understands gas/custody implications.

### 4. Read ABI Proof

Create:

```text
docs/read-abi-proof.md
```

The facilitator currently needs these reads:

```text
channels(bytes32)
pendingWithdrawals(bytes32)
refundNonce(bytes32)
```

Record for each:

```text
method signature
selector
sample channelId
calldata
raw eth_call return bytes
decoded fields
```

Compare directly against facilitator PR #101 assumptions:

```text
channels(bytes32)
  expected word 0 = balance
  expected word 1 = totalClaimed

pendingWithdrawals(bytes32)
  expected withdrawRequestedAt location must be proven from ABI/source

refundNonce(bytes32)
  expected uint256
```

If the ABI differs, do not work around it in documentation. Create a follow-up
facilitator fix task.

## Contract Lifecycle To Prove

At minimum, prove read compatibility against an empty channel.

If test token/deployer setup is available, also prove a tiny lifecycle:

```text
1. deploy x402BatchSettlement
2. deploy ERC3009DepositCollector and/or Permit2DepositCollector
3. create/top-up a channel with a tiny test amount
4. read channels(channelId)
5. claim one small voucher
6. read channels(channelId) again and confirm totalClaimed changed
7. call settle(receiver, token)
8. confirm claimed funds move to receiver
9. inspect refund/withdrawal read shapes
```

Keep amounts tiny. This project is for proof, not production liquidity.

## Audit And Custody Notes

This repo must contain:

```text
docs/audit-and-risk-notes.md
```

Required notes:

- The batch-settlement contract carries escrowed buyer funds.
- The deployment is custody-relevant from a product risk perspective even if the
  contract is non-custodial and rules-based.
- For public experimentation, use tiny-value deployments and clear disclaimers.
- For production, prefer official audited x402 artifacts if available.
- If the official contract is copied without modification, preserve provenance
  and audit references.
- If any source, compiler settings, constructor args, deployment method, or
  linked dependency differs from the audited official artifact, treat the XDC
  deployment as needing fresh review before meaningful TVL.
- Before commercial launch, get legal/compliance review for the operating
  model, especially if the facilitator controls authorizer keys, custody keys,
  pooled balances, merchant onboarding, fees, or refund/withdrawal workflows.

Important distinction:

```text
The contract can be non-custodial at the code level, but the product can still
create custody, money-transmission, or payment-service obligations depending on
who controls keys, who can move funds, and how the service is marketed/operated.
```

## README Requirements

The public README should explain:

```text
This repository deploys the official x402 batch-settlement EVM contracts to XDC
for compatibility testing and public verification.
```

Include:

- upstream source link and commit SHA
- license and attribution summary
- deployed XDC addresses once available
- XDC explorer verification links
- opcode probe summary
- read ABI proof link
- warning that this is not yet a production custody recommendation
- link back to the facilitator repo
- disclaimer that this is not official x402/XDC endorsement unless explicitly
  approved

## Acceptance Criteria

- Public repo is created with clear name and README.
- Official x402 source/artifact is pinned by commit SHA.
- Upstream license is verified from the pinned commit.
- Root `LICENSE` is compatible with upstream.
- Attribution/notice requirements are satisfied.
- SPDX headers and upstream notices are preserved.
- Trademark/endorsement disclaimer is present.
- Any source modifications are explicit; ideally there are none.
- Contracts compile reproducibly.
- EIP-1153/XDC opcode probe is documented.
- Deployment is recorded, or blocker is documented precisely.
- XDC explorer source/bytecode verification links are recorded.
- Read ABI proof confirms or rejects facilitator PR #101 assumptions.
- Audit/risk notes exist and are clear.
- No private keys, RPC secrets, or production credentials are committed.
- No facilitator code is changed in this side project.

## Suggested PR Notes Template

```text
## Summary

- Creates a public XDC deployment/proof repo for the official x402
  batch-settlement EVM contracts.
- Pins upstream x402 source provenance and documents XDC opcode compatibility.
- Adds deployment scripts and records deployed contract addresses / explorer
  verification links.
- Captures raw read ABI proof for `channels(bytes32)`,
  `pendingWithdrawals(bytes32)`, and `refundNonce(bytes32)`.
- Documents audit, custody, and production-risk notes.

## Test plan

- [ ] Confirm upstream x402 commit SHA
- [ ] Confirm upstream license and preserve SPDX headers
- [ ] Add compatible root LICENSE and NOTICE/attribution if needed
- [ ] Add non-endorsement/trademark disclaimer
- [ ] Compile official contracts reproducibly
- [ ] Run/document EIP-1153 opcode probe
- [ ] Deploy to chosen XDC environment
- [ ] Verify source/bytecode on XDC explorer
- [ ] Capture raw read-call outputs
- [ ] Confirm facilitator reader ABI compatibility
- [ ] Confirm no private keys or secrets are committed
```

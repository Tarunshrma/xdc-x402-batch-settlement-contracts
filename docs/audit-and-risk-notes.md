# Audit and risk notes

This repository deploys (or prepares to deploy) the official x402
`batch-settlement` EVM contracts onto XDC. It is a public compatibility
proof, not a production custody recommendation.

## Escrow and product risk

The batch-settlement contract carries escrowed buyer funds. Channels hold
ERC-20 balances until they are claimed, settled, refunded, or withdrawn
under the contract rules.

The deployment is custody-relevant from a product risk perspective even if
the contract is non-custodial and rules-based.

Important distinction:

```text
The contract can be non-custodial at the code level, but the product can still
create custody, money-transmission, or payment-service obligations depending on
who controls keys, who can move funds, and how the service is marketed/operated.
```

Examples of product-level control that can create obligations even with
unmodified bytecode:

- Facilitator or operator control of `receiverAuthorizer` keys
- Control of payer keys or pooled balances
- Merchant onboarding, fees, or refund/withdrawal operations performed as a service

Before commercial launch, get legal and compliance review of the operating
model.

## Experimentation vs production

For public experimentation, use tiny-value deployments and the disclaimers in
the README. Do not seed meaningful TVL on an unverified or unaudited-for-XDC
deployment.

For production, prefer official audited x402 artifacts if available, with
matching compiler settings, bytecode, constructor args, and CREATE2 path.

## Provenance and audits

Official contract source in this repo is copied without modification from
`x402-foundation/x402` commit `84ffb6412a1f2f45a62971c5549eff794281c099`.
See `docs/provenance.md`.

Upstream audit PDFs are **linked, not copied**:

- https://github.com/x402-foundation/x402/tree/84ffb6412a1f2f45a62971c5549eff794281c099/contracts/evm/audits

Those reports cover upstream artifacts and chains as described by the
auditors. They do not automatically certify an XDC deployment.

If any source, compiler settings, constructor args, deployment method, or
linked dependency differs from the audited official artifact, treat the XDC
deployment as needing fresh review before meaningful TVL.

This repo's intended path is: unmodified source + official `foundry.toml`
bytecode settings + official CREATE2 factory/salts + canonical Permit2. If
that path succeeds, bytecode should match other EVM deployments of the same
commit. Confirm by comparing deployed bytecode and explorer verification.

## XDC-specific residual risk

- EIP-1153 is probed at runtime (`docs/xdc-opcode-probe.md`) but a probe is
  not a substitute for a successful deploy and method calls.
- CREATE2 factory and Permit2 were observed on XDC mainnet and Apothem at
  the canonical addresses. Re-check before every deploy.
- Explorer verification quality varies; keep compiler metadata and source
  links in `docs/deployment-record.md`.
- Tokens on XDC may not behave like USDC on Base (fee-on-transfer, rebasing,
  missing ERC-3009). The official contract already warns that such tokens
  are not guaranteed.

## This repo's posture

Independent XDC deployment/proof project. Not official x402, Coinbase, Base,
or XDC endorsement unless those parties explicitly approve it.

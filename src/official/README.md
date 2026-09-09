# Official x402 sources

Solidity in this Foundry project is copied **verbatim** from
[`x402-foundation/x402`](https://github.com/x402-foundation/x402) commit
`84ffb6412a1f2f45a62971c5549eff794281c099`.

Files keep the upstream `contracts/evm/src/` relative layout so official
imports and `script/DeployBatchSettlement.s.sol` do not need edits:

```text
src/x402BatchSettlement.sol
src/interfaces/
src/periphery/
```

Do not modify those files in this repository. If a change is required, record
the exact diff in `docs/provenance.md` and treat it as a new review surface.

See `docs/provenance.md` for SHAs, license notes, and audit links.

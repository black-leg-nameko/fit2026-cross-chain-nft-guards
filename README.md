# FIT2026 Cross-Chain NFT Operation Guards

This repository contains the proof-of-concept implementation for the FIT2026
paper "Defining and Preventing Hazardous Operations under Ownership
Inconsistency in Cross-chain NFTs".

The PoC compares:

- `BaselineNFT`: a naive cross-chain NFT that emits bridge events but keeps
  ownership-dependent NFT operations available while a bridge transfer is
  pending.
- `SafeCrossChainNFT`: a state-aware NFT that tracks `ACTIVE`, `PENDING_OUT`,
  and `PENDING_IN` per token and rejects hazardous operations during pending
  states.
- `MockMarketplace`: a minimal bridge-aware marketplace that treats listing as
  an ownership-dependent operation.

## Hazardous Operations

The implementation guards the three operations used in the paper:

- transfer: `transferFrom`, `safeTransferFrom`
- approval: `approve`, `setApprovalForAll`
- listing: marketplace listing through `canList(tokenId)`

## Build

The contracts have no external Solidity dependencies and can be compiled with a
plain `solc`:

```bash
solc --base-path . --include-path . --bin --abi src/*.sol -o out --overwrite
```

If Foundry is available, the project layout is also Foundry-compatible:

```bash
forge build
```

## Scenario Check

The repository includes a dependency-free Node.js scenario runner that mirrors
the paper's comparison table:

```bash
node scripts/run_scenarios.js
```

It writes `results/scenario_report.json` and prints whether each pending-state
operation succeeds in the baseline and is rejected by the proposal.

## Expected Result

| Scenario | Baseline | Proposal |
| --- | --- | --- |
| pending transfer | succeeds | rejected |
| pending approve | succeeds | rejected |
| pending listing | succeeds | rejected |
| transfer after finalize | succeeds | succeeds |
| replay finalize | accepted | rejected |

This PoC intentionally abstracts bridge signature verification and focuses on
ownership-state semantics and operation guards.

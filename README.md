# EVVM Testnet Contracts

![](https://github.com/user-attachments/assets/08d995ee-7512-42e4-a26c-0d62d2e8e0bf)

The Ethereum Virtual Virtual Machine (EVVM) ⚙️

**This repository is the next step after successful playground testing. It is dedicated to advanced integration, deployment, and validation on public testnets, before mainnet implementation.**

EVVM provides a comprehensive set of smart contracts and tools for scalable, modular, and cross-chain EVM virtualization. This repo is intended for developers who want to:
- Test and validate contracts on public testnets (Ethereum Sepolia, Arbitrum Sepolia)
- Prepare for mainnet deployment after testnet validation
- Contribute to the evolution of the EVVM protocol

## Repository Structure
- `src/evvm/` — Core EVVM contracts and storage
- `src/mns/` — MateNameService (MNS) contracts
- `src/staking/` — Staking and Estimator contracts
- `src/libraries/` — Shared Solidity libraries
- `script/` — Deployment and automation scripts (e.g., `DeployTestnet.s.sol`)
- `test/` — (If present) Test contracts for local and CI validation

## Contract Addresses

### Ethereum Sepolia Testnet
- **EVVM**: [0x4fb6f9CDe625b9436dF1653d2ee99388C90215EA](https://sepolia.etherscan.io/address/0x4fb6f9cde625b9436df1653d2ee99388c90215ea#code)
- **MateNameService**: [0x166b4207da35740e38e55B09819fdFAdF27401cD](https://sepolia.etherscan.io/address/0x166b4207da35740e38e55b09819fdfadf27401cd#code)
- **SMate**: [0xD4C37ed2C0A4de515382d2EEa0940ea99234Ca72](https://sepolia.etherscan.io/address/0xd4c37ed2c0a4de515382d2eea0940ea99234ca72#code)
- **Estimator**: [0xAF4387cC9105C9B716B9B84F673996dCa7ac5150](https://sepolia.etherscan.io/address/0xaf4387cc9105c9b716b9b84f673996dca7ac5150#code)

### Arbitrum Sepolia Testnet
- **EVVM**: [0x15d2D6c2b3037bf11fa889dF7a31A8A4ECf2A551](https://sepolia.arbiscan.io/address/0x15d2d6c2b3037bf11fa889df7a31a8a4ecf2a551#code)
- **MateNameService**: [0x86A2a79564582fE2Ff7707995Bf3f191EE21BEe5](https://sepolia.arbiscan.io/address/0x86a2a79564582fe2ff7707995bf3f191ee21bee5#code)
- **SMate**: [0x1EBA2e0F2B36182401135965498fd28014d42064](https://sepolia.arbiscan.io/address/0x1eba2e0f2b36182401135965498fd28014d42064#code)
- **Estimator**: [0xc0E73Ec2b09F4F26EA1D19dBdf7b9b0B6116F6d1](https://sepolia.arbiscan.io/address/0xc0e73ec2b09f4f26ea1d19dbdf7b9b0b6116f6d1#code)

## Development Flow
1. **Playground**: Prototype and experiment with new features in the playground repo.
2. **Testnet (this repo)**: Integrate, test, and validate on public testnets (testnet6).
3. **Mainnet**: After successful testnet validation, proceed to mainnet deployment.

## Prerequisites
- [Foundry](https://getfoundry.sh/) (Solidity development toolkit)
- Node.js (for dependency management)

## Key Dependencies
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Chainlink CCIP](https://github.com/smartcontractkit/ccip)
- [Axelar GMP](https://github.com/axelarnetwork/axelar-gmp-sdk-solidity)
- [Hyperlane](https://github.com/hyperlane-xyz/hyperlane-monorepo)
- [LayerZero OApp](https://github.com/LayerZero-Labs/LayerZero-v2)
- [Uniswap v3](https://github.com/Uniswap/v3-core)

## Quick Start
```bash
git clone https://github.com/EVVM-org/EVVM-Contracts
cd EVVM-Contracts
make install
```

## Installation
Install dependencies and compile contracts:
```bash
make install
```

## Local Development
Start a local Anvil chain:
```bash
make anvil
```

## Deployment
Deploy contracts to Ethereum Sepolia testnet:
```bash
make deployTestnet NETWORK=eth
```
Deploy contracts to Arbitrum Sepolia testnet:
```bash
make deployTestnet NETWORK=arb
```

## Compilation
Recompile contracts:
```bash
make compile
```
Check contract sizes:
```bash
make seeSizes
```

## Contributing
1. Fork the repository
2. Create a feature branch and make changes
3. Add tests for new features
4. Submit a PR with a detailed description

> **Security Note**: Never commit real private keys. Use test credentials only.

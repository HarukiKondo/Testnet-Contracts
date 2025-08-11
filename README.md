# EVVM Testnet Contracts

![](https://github.com/user-attachments/assets/08d995ee-7512-42e4-a26c-0d62d2e8e0bf)

The Ethereum Virtual Virtual Machine (EVVM) ⚙️

**This repository is the next step after successful playground testing. It is dedicated to advanced integration, deployment, and validation on public testnets, before mainnet implementation.**

EVVM provides a comprehensive set of smart contracts and tools for scalable, modular, and cross-chain EVM virtualization. This repo is intended for developers who want to:
- Test and validate contracts on public testnets (Ethereum Sepolia, Arbitrum Sepolia)
- Prepare for mainnet deployment after testnet validation
- Contribute to the evolution of the EVVM protocol

## Repository Structure
- `src/contracts/evvm/` — Core EVVM contracts and storage
- `src/contracts/nameService/` — NameService contracts for domain management
- `src/contracts/staking/` — Staking and Estimator contracts
- `src/lib/` — Shared Solidity libraries (AdvancedStrings, SignatureRecover, etc.)
- `script/` — Deployment and automation scripts (e.g., `DeployTestnet.s.sol`)
- `lib/` — External dependencies (OpenZeppelin, Uniswap v3, forge-std)
- `broadcast/` — Foundry deployment artifacts and transaction history
- `cache/` — Foundry compilation cache

## Public EVVM Contract Address

### Ethereum Sepolia Testnet
- **EVVM**: [0x1256f895Da1c58f47CA3F9Ca89f88e60275fEe9c](https://sepolia.etherscan.io/address/0x1256f895Da1c58f47CA3F9Ca89f88e60275fEe9c#code)
- **NameService**: [0x5e610944934b688890390f3d63397fb3b85528f3](https://sepolia.etherscan.io/address/0x5e610944934b688890390f3d63397fb3b85528f3#code)
- **Staking**: [0x50dcf8b764d6583063372186Cf4818356BBE4dD6](https://sepolia.etherscan.io/address/0x50dcf8b764d6583063372186Cf4818356BBE4dD6#code)
- **Estimator**: [0xA3E93E38a509EDCF7d4D4B4B34C8e0222F4d038D](https://sepolia.etherscan.io/address/0xA3E93E38a509EDCF7d4D4B4B34C8e0222F4d038D#code)

### Arbitrum Sepolia Testnet
- **EVVM**: [0xC1ef02492F1A75bCdB20766B558f10D643f9d504](https://sepolia.arbiscan.io/address/0xC1ef02492F1A75bCdB20766B558f10D643f9d504#code)
- **NameService**: [0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309](https://sepolia.arbiscan.io/address/0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309#code)
- **Staking**: [0x9BB0ABD0AB28FD1704589D65806Ab1E88c78A280](https://sepolia.arbiscan.io/address/0x9BB0ABD0AB28FD1704589D65806Ab1E88c78A280#code)
- **Estimator**: [0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309](https://sepolia.arbiscan.io/address/0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309#code)

## Development Flow
1. **Playground**: Prototype and experiment with new features in the playground repo.
2. **Testnet (this repo)**: Integrate, test, and validate on public testnets.
3. **Mainnet**: After successful testnet validation, proceed to mainnet deployment.

## Prerequisites
- [Foundry](https://getfoundry.sh/) (Solidity development toolkit)
- Node.js (for dependency management)

## Key Dependencies
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Chainlink CCIP](https://docs.chain.link/ccip)
- [Axelar GMP](https://github.com/axelarnetwork/axelar-gmp-sdk-solidity)
- [Hyperlane](https://github.com/hyperlane-xyz/hyperlane-monorepo)
- [LayerZero OApp](https://github.com/LayerZero-Labs/LayerZero-v2)
- [Uniswap v3](https://github.com/Uniswap/v3-core)

## Quick Start
```bash
git clone https://github.com/EVVM-org/Testnet-Contracts
cd Testnet-Contracts
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

Deploy contracts to local testnet:
```bash
make deployLocalTestnet
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

## Compilation and Testing
Recompile contracts:
```bash
make compile
```
Check contract sizes:
```bash
make seeSizes
```

## Available Commands
Get help with all available commands:
```bash
make help
```

## Configuration Files
- `foundry.toml` — Foundry project configuration with remappings
- `package.json` — Node.js dependencies for cross-chain protocols
- `makefile` — Build and deployment automation
- `wake.toml` — Wake tooling configuration

## Contract Architecture
The EVVM ecosystem consists of four main contracts:
- **Evvm.sol**: Core virtual machine implementation
- **NameService.sol**: Domain name resolution system  
- **Staking.sol**: Token staking and rewards mechanism
- **Estimator.sol**: Staking rewards estimation and calculation

## Contributing
1. Fork the repository
2. Create a feature branch and make changes
3. Add tests for new features
4. Submit a PR with a detailed description

> **Security Note**: Never commit real private keys. Use test credentials only.

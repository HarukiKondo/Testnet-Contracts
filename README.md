# EVVM contracts

![](https://github.com/user-attachments/assets/08d995ee-7512-42e4-a26c-0d62d2e8e0bf)


The Ethereum Virtual Virtual Machine ⚙️ Infraless EVM Virtualization solving Scalability and Chain Fragmentation 🔧

If you want to test or build on the EVVM contracts, this repository provides a comprehensive set of smart contracts and tools for local development, testing, and deployment.

## Contract addresses

- **EVVM**: [0x361b3257fC6aEf19f3Cf0ff5cD12911f80176273](https://sepolia.arbiscan.io/address/0x361b3257fc6aef19f3cf0ff5cd12911f80176273#code)

- **MateNameService**: [0x64d5C5f667AeefDa7E926b66CEa384F529c01372](https://sepolia.arbiscan.io/address/0x64d5c5f667aeefda7e926b66cea384f529c01372#code)

- **SMate**: [0xeF3A784e195a224BE1d5525E23E06E3A029022b7](https://sepolia.arbiscan.io/address/0xef3a784e195a224be1d5525e23e06e3a029022b7#code)

- **Estimator**: [0xdA441Cd599F8d61bc809119EED847A0fE7c469aa](https://sepolia.arbiscan.io/address/0xda441cd599f8d61bc809119eed847a0fe7c469aa#code)

> **Note**: These contracts are deployed on Arbitrum Sepolia testnet.



## Prerequisites

- [Foundry](https://getfoundry.sh/)
- Node.js (for package management)

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

Start local Anvil chain:
```bash
make anvil
```

## Deployment

Deploy contracts to Arbitrum Sepolia testnet:
```bash
make deployTestnet
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

1. Fork repository
2. Create feature branch and make changes inside the mock contracts
3. Add tests for new features
4. Submit PR with detailed description

> **Security Note**: Never commit real private keys. Use test credentials only.


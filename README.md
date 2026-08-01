# Kveltaar Institutional Wallet

Enterprise-grade ERC-4337 smart account designed for institutional digital asset management.

Built with Solidity 0.8.28, OpenZeppelin, ERC-4337 Account Abstraction and Foundry.

---

## Overview

Kveltaar Institutional Wallet is a modular smart account architecture implementing ERC-4337 Account Abstraction for institutional environments.

The wallet introduces role-based operational governance, treasury separation, emergency controls and secure transaction execution while remaining compatible with the ERC-4337 EntryPoint architecture.

The project consists of:

- Institutional Smart Wallet
- CREATE2 Wallet Factory
- Deterministic wallet deployment
- Full Foundry test suite
- Static security analysis with Slither
- Verified contracts on Sepolia

---

## Key Features

- ERC-4337 Account Abstraction
- CREATE2 deterministic deployment
- Role-based access control
- Treasury role
- Operator role
- Compliance Officer role
- Emergency pause / unpause
- Reentrancy protection
- EntryPoint deposit management
- Secure native asset transfers
- Unauthorized execution protection
- Institutional governance model

---

## Architecture

```text
                       +----------------------+
                       |     EntryPoint       |
                       |      ERC-4337        |
                       +----------+-----------+
                                  |
                                  |
                    validateUserOp()
                                  |
                                  v
          +---------------------------------------+
          | KveltaarInstitutionalWallet           |
          |---------------------------------------|
          | Owner                                |
          | Treasury Role                        |
          | Operator Role                        |
          | Compliance Role                      |
          | Pause / Unpause                      |
          | Native Asset Management              |
          +------------------+-------------------+
                             |
                             |
                  CREATE2 Deployment
                             |
                             |
          +------------------v-------------------+
          | KveltaarWalletFactory               |
          +--------------------------------------+
```

---

## Technology Stack

- Solidity 0.8.28
- Foundry
- OpenZeppelin Contracts
- ERC-4337 Account Abstraction
- EntryPoint
- CREATE2
- Slither
- GitHub Actions
- Sepolia Testnet

---

## Smart Contracts

### Wallet Factory

https://sepolia.etherscan.io/address/0xF77Cc2F14D6B2C9E3c19345F5A7f3E791D7445F6

Verified on Etherscan

### Institutional Wallet

https://sepolia.etherscan.io/address/0xea3e3D9bc728421367e2D63283B7F2aB6957fbE2

Verified on Etherscan

---

## Security

Security mechanisms implemented:

- Role-based authorization
- AccessControl
- ReentrancyGuard
- Pausable emergency stop
- EntryPoint validation
- Unauthorized execution protection
- Treasury withdrawal restrictions

Static analysis performed using:

- Slither

Continuous Integration:

- GitHub Actions
- Automatic build
- Automatic formatting checks
- Automatic test execution

---

## Test Coverage

Current test suite validates:

- Wallet initialization
- Role assignment
- Treasury deposit
- Treasury withdrawal
- EntryPoint deposits
- Native asset reception
- Operator execution
- Unauthorized execution rejection
- Pause functionality
- Unpause functionality
- Factory deployment
- Deterministic CREATE2 addresses

---

## Test Results

### Development Environment

![Foundry Overview](docs/images/foundry-tests-overview.png)

---

### Successful Test Execution

![Foundry Tests](docs/images/foundry-tests-summary.png)

All smart contract tests pass successfully.

```
18 tests passed
0 failed
0 skipped
```

---

## Static Analysis

Static security analysis completed using Slither.

No critical security vulnerabilities identified.

---

## Build

```bash
forge build
```

Run tests

```bash
forge test -vvv
```

Run Slither

```bash
slither .
```

---

## Project Structure

```
src/
script/
test/
docs/
lib/
```

---

## License

MIT

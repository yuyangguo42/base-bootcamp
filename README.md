
# About this repo
Just doing some Solidity / Base exercise from https://docs.base.org/base-camp/

# Setup
Copy .env.sample to .env

# Foundry Instructions
## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Dependencies
#### Step 1: forge install

e.g. To install https://github.com/eth-infinitism/account-abstraction
```shell
$ forge install eth-infinitism/account-abstraction
```
#### Step 2: add remapping to foundry.toml
```
remappings = [
    "@account-abstraction/=lib/account-abstraction/contracts",
    ...
]
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

(Not sure what's the diff between this and above)

Set env var `ETH_RPC_URL`

```
forge create src/mapping.sol:FavoriteRecords --mnemonic-path=$BASE_BOOTCAMP_WALLET
```

Example
```
forge create src/math.sol:BasicMath --mnemonic-path=$BASE_BOOTCAMP_WALLET --verify --chain-id=84531 --etherscan-api-key=base-goerli --constructor-args <arg1> <arg2>
```

### Contract verification
``
forge v <address> <contract> --chain-id=84531 --etherscan-api-key=base-goerli
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

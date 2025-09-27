# WorldCircle

A Solidity smart contract to track people, events, and connections on-chain.

## Start local chain

```bash
anvil
```

## Setup

```bash
forge install
```

```bash
forge build
```

## testing

```bash
forge test
```

## Deploy

```bash
export PRIVATE_KEY="0xac0974bec39....5efcae784d7bf4f2ff80"
forge script script/WorldCircle.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key $PRIVATE_KEY
```

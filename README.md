## Description

NFT token on Binance Smart Chain

## Installation

```bash
$ npm install
```

## Configuration
Create a `.env` file in this folder with the following content. 
```
MNEMONIC_PRIVATEKEY=

```
* **MNEMONIC_PRIVATEKEY** Private key word seed of the Owner and deployer of this contracts.
* Optionally you can set a value for `NETWORK_GAS_PRICE` 
> Change those values for production environments

## Deploy

```bash
# Migrate contracts to a public network, defined with .env
$ npm run migrate
```

## Test

```bash
# unit tests
$ npm run test
```

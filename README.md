## Description

NFT token on Binance Smart Chain

## Run for development

1. Run ganache-cli in a parallel terminal

    ```bash
    npx ganache-cli -i 5777 -p 7545
    ```

2. Copy the mnemonic from ganache-cli into the `MNEMONIC_PRIVATEKEY` env variable

3. Copy the first private key from ganache-cli: this will be the platform admin account so it will be useful to import it in metamask

4. install and deploy

    ```bash
    npm i
    npm run migrate:local
    ```

5. Copy the address displayed in `Kargain Contract:`, this address will be needed in the `kargain-app` env file

## Configuration

Create a `.env` file in this folder with the following content.

```ini
MNEMONIC_PRIVATEKEY=
```

* **MNEMONIC_PRIVATEKEY** Private key word seed of the Owner and deployer of this contracts.
* Optionally you can set a value for `NETWORK_GAS_PRICE` 

> Change those values for production environments

## Test

```bash
npm run test
```

## Vesting contracts for project owners and investors after token launch
Vesting contracts for custom ERC20 token

## Features

- Add recipients to vesting schedule alone or in batch
- Linearly release vested tokens to recipients over a predefined vesting period
- LinearVesting.sol contract for custom ERC20 token and VestingERC20.sol contract for standard ERC20 token
- Vesting.sol with initial timelock for vested shares and release the shares monthly


## Prerequisites

Please install or have installed the following:

- [nodejs and npm](https://nodejs.org/en/download/)
- [python](https://www.python.org/downloads/)
## Installation

1. [Install Brownie](https://eth-brownie.readthedocs.io/en/stable/install.html), if you haven't already. Here is a simple way to install brownie.

```bash
pip install eth-brownie
```
Or, if that doesn't work, via pipx
```bash
pip install --user pipx
pipx ensurepath
# restart your terminal
pipx install eth-brownie
```

2. Clone this repo
```
git clone https://github.com/mikaelaakko/vesting-contracts.git
cd vesting-contracts
```

1. [Install ganache-cli](https://www.npmjs.com/package/ganache-cli)

```bash
npm install -g ganache-cli
```

If you want to be able to deploy to testnets, do the following. 

4. Set your environment variables

Set your `WEB3_INFURA_PROJECT_ID`, and `PRIVATE_KEY` [environment variables](https://www.twilio.com/blog/2017/01/how-to-set-environment-variables.html). 

You can get a `WEB3_INFURA_PROJECT_ID` by getting a free trial of [Infura](https://infura.io/). At the moment, it does need to be infura with brownie. You can find your `PRIVATE_KEY` from your ethereum wallet like [metamask](https://metamask.io/). 

You'll also need testnet rinkeby ETH. You can get ETH into your wallet by using the [rinkeby faucets located here](https://docs.chain.link/docs/link-token-contracts#rinkeby).

You can add your environment variables to `.env` file excluded from this repository:

```
export WEB3_INFURA_PROJECT_ID=<PROJECT_ID>
export PRIVATE_KEY=<PRIVATE_KEY>
```

AND THEN RUN `source .env` TO ACTIVATE THE ENV VARIABLES
(You'll need to do this everytime you open a new terminal, or [learn how to set them easier](https://www.twilio.com/blog/2017/01/how-to-set-environment-variables.html))


Or you can run the above in your shell. 


# Usage

The NFT smart contract is in the `contracts` folder: 
- `LinearVesting.sol`
- `VestingERC20.sol`

You can use the rinkeby testnet or any other testnet, but it's suggested that you test and build first on a local development network so you don't have to wait as long for transactiona confirmations. 

### Running Scripts

```
brownie run scripts/deploy.py --network rinkeby
```

You'll need [testnet Rinkeby](https://faucet.rinkeby.io/) in the wallet associated with your private key. 


## Verify on Etherscan

 The contract can be verified if you just set your `ETHERSCAN_TOKEN` in your environment variables and define `publish_source` as `True` in `deploy.py` script. 

### Misc
There are helper functions in `helper_functions.py`.

## License

This project is licensed under the [MIT license](LICENSE).

from brownie import LinearVesting, Contract
from scripts.helper_functions import get_account

custom_token_address = "0x61c2984d0D60e8C498bdEE6dbE4A4E83E53ecfE8"
amount = 1000000 * 10 ** 18


def deploy():
    account = get_account()
    publish_source = True
    vesting = LinearVesting.deploy(
        custom_token_address,
        {"from": account},
        publish_source=publish_source,
    )
    print(f"Contract {vesting.address} deployed succesfully!")
    print(
        f"View the contract at https://rinkeby.etherscan.io/address/{vesting.address}"
    )


def load_tokens():
    account = get_account()
    vesting = LinearVesting[-1]
    custom_token = Contract(custom_token_address)
    custom_token.transfer(vesting.address, amount, {"from": account})


def add_new_recipient():
    account = get_account()
    vesting = LinearVesting[-1]
    vesting.addNewRecipient(account, amount, {"from": account})


def withdraw():
    account = get_account()
    vesting = LinearVesting[-1]
    vesting.withdrawToken(account, {"from": account})


def print_values():
    account = get_account()
    vesting = LinearVesting[-1]
    print("Amount locked: ", vesting.getLocked(account))
    print("Amount withdrawable: ", vesting.getWithdrawable(account))
    print("LOLLOL:", vesting.getVested(account))


def main():
    deploy()
    load_tokens()
    add_new_recipient()
    print_values()
    # withdraw()

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CustomToken is ERC20, Ownable {
    using SafeMath for uint256;

    string public constant NAME = "Your Custom Token";
    string public constant SYMBOL = "YCT";
    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 500e9 * (10**uint256(DECIMALS));
    address public multiSigAdmin;

    event MultiSigAdminUpdated(address _multiSigAdmin);

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() Ownable() ERC20(NAME, SYMBOL) {
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    /**
     * @dev Override decimals() function to customize decimals
     */
    function decimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }

    function setMultiSigAdminAddress(address _multiSigAdmin)
        external
        onlyOwner
    {
        require(
            _multiSigAdmin != address(0x00),
            "Invalid MultiSig admin address"
        );
        multiSigAdmin = _multiSigAdmin;
        emit MultiSigAdminUpdated(multiSigAdmin);
    }

    /**
     * @dev Recovers the ERC20 token balance mistakenly sent to the contract. Only multisig contract can call this function
     * @param tokenAddress The token contract address
     * @param tokenAmount Number of tokens to be sent
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        onlyMultiSigAdmin
    {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    // modifier for multiSig only
    modifier onlyMultiSigAdmin() {
        require(msg.sender == multiSigAdmin, "Should be multiSig contract");
        _;
    }
}

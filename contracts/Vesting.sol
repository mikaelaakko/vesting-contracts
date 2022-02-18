// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IERC20.sol";

contract VestingERC20 is Ownable {
    using SafeMath for uint256;

    struct VestingSchedule {
        uint256 totalAmount; // Total amount of tokens to be vested.
        uint256 amountWithdrawn; // The amount that has been withdrawn.
        uint256 startTime;
    }

    mapping(address => VestingSchedule) public recipients;

    uint256 private totalAllocated; // The amount of allocated tokens
    uint256 public immutable vestingPeriod = 360 days;
    uint256 constant initialLock = 30 days; // No tokens will be unlocked for the first 45 days

    event VestingScheduleRegistered(
        address registeredAddress,
        uint256 totalAmount
    );
    event VestingSchedulesRegistered(
        address[] registeredAddresses,
        uint256[] totalAmounts
    );

    IERC20 public customToken;

    constructor(address _customToken) {
        customToken = IERC20(_customToken);
    }

    /**
     * @dev Private function to add a recipient to vesting schedule
     * @param _recipient the address to be added
     * @param _totalAmount integer variable to indicate token amount of the recipient
     */

    function addRecipient(address _recipient, uint256 _totalAmount) private {
        require(
            _recipient != address(0x00),
            "addRecipient: Invalid recipient address"
        );
        require(_totalAmount > 0, "addRecipient: Cannot vest 0");
        require(
            recipients[_recipient].totalAmount < _totalAmount,
            "Cannot override previous vesting"
        );

        totalAllocated = totalAllocated
            .sub(recipients[_recipient].totalAmount)
            .add(_totalAmount);
        require(
            totalAllocated <= customToken.balanceOf(address(this)),
            "addRecipient: Total Allocation Overflow"
        );

        totalAllocated = totalAllocated
            .sub(recipients[_recipient].totalAmount)
            .add(_totalAmount);

        recipients[_recipient] = VestingSchedule({
            totalAmount: _totalAmount,
            amountWithdrawn: 0,
            startTime: block.timestamp
        });
    }

    /**
     * @dev Add new recipient to vesting schedule
     * @param _newRecipient the address to be added
     * @param _totalAmount integer variable to indicate token amount of the recipient
     */

    function addNewRecipient(address _newRecipient, uint256 _totalAmount)
        external
        onlyOwner
    {
        addRecipient(_newRecipient, _totalAmount);

        emit VestingScheduleRegistered(_newRecipient, _totalAmount);
    }

    /**
     * @dev Add new recipients to vesting schedule
     * @param _newRecipients the addresses to be added
     * @param _totalAmounts integer array to indicate token amount of recipients
     */

    function addNewRecipients(
        address[] memory _newRecipients,
        uint256[] memory _totalAmounts
    ) external onlyOwner {
        for (uint256 i = 0; i < _newRecipients.length; i++) {
            addRecipient(_newRecipients[i], _totalAmounts[i]);
        }

        emit VestingSchedulesRegistered(_newRecipients, _totalAmounts);
    }

    /**
     * @dev Gets the locked token amount of a beneficiary
     * @param beneficiary address of beneficiary
     */
    function getLocked(address beneficiary) external view returns (uint256) {
        return recipients[beneficiary].totalAmount.sub(getVested(beneficiary));
    }

    /**
     * @dev Gets the claimable token amount of a beneficiary
     * @param beneficiary address of beneficiary
     */
    function getWithdrawable(address beneficiary)
        public
        view
        returns (uint256)
    {
        return
            getVested(beneficiary).sub(recipients[beneficiary].amountWithdrawn);
    }

    /**
     * @dev Claim unlocked token tokens of a recipient
     * @param _recipient address of recipient
     */
    function withdrawToken(address _recipient) external returns (uint256) {
        VestingSchedule storage _vestingSchedule = recipients[msg.sender];
        if (_vestingSchedule.totalAmount == 0) return 0;

        uint256 _vested = getVested(msg.sender);
        uint256 _withdrawable = _vested.sub(
            recipients[msg.sender].amountWithdrawn
        );
        _vestingSchedule.amountWithdrawn = _vested;

        require(_withdrawable > 0, "withdraw: Nothing to withdraw");
        require(customToken.transfer(_recipient, _withdrawable));

        return _withdrawable;
    }

    /**
     * @dev Get claimable custom token amount of a beneficiary
     * @param beneficiary address of beneficiary
     */
    function getVested(address beneficiary)
        public
        view
        virtual
        returns (uint256 _amountVested)
    {
        require(beneficiary != address(0x00), "getVested: Invalid address");
        VestingSchedule memory _vestingSchedule = recipients[beneficiary];

        if (
            (_vestingSchedule.totalAmount == 0) ||
            (block.timestamp < _vestingSchedule.startTime)
        ) {
            return 0;
        }

        uint256 vestedPercent = 0;
        uint256 firstVestingPoint = _vestingSchedule.startTime.add(initialLock);

        uint256 secondVestingPoint = firstVestingPoint.add(vestingPeriod);
        if (
            block.timestamp > firstVestingPoint &&
            block.timestamp <= secondVestingPoint
        ) {
            vestedPercent =
                1000 +
                (block.timestamp - firstVestingPoint).mul(9000).div(
                    vestingPeriod
                );
        } else if (block.timestamp > secondVestingPoint) {
            vestedPercent = 10000;
        }

        uint256 vestedAmount = _vestingSchedule
            .totalAmount
            .mul(vestedPercent)
            .div(10000);
        if (vestedAmount > _vestingSchedule.totalAmount) {
            return _vestingSchedule.totalAmount;
        }

        return vestedAmount;
    }
}

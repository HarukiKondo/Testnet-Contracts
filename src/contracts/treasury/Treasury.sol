// SPDX-License-Identifier: EVVM-NONCOMMERCIAL-1.0
// Full license terms available at: https://www.evvm.org/docs/EVVMNoncommercialLicense

pragma solidity ^0.8.0;

/**
 * @title Treasury Contract
 * @author jistro.eth
 * @notice Treasury for managing deposits and withdrawals in the EVVM ecosystem
 * @dev Secure vault for ETH and ERC20 tokens with EVVM integration and input validation
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeTransferLib} from "@solady/utils/SafeTransferLib.sol";
import {Evvm} from "@EVVM/testnet/contracts/evvm/Evvm.sol";
import {ErrorsLib} from "@EVVM/testnet/contracts/treasury/lib/ErrorsLib.sol";

contract Treasury {
    /// @notice Address of the EVVM core contract
    address public evvmAddress;

    /**
     * @notice Initialize Treasury with EVVM contract address
     * @param _evvmAddress Address of the EVVM core contract
     */
    constructor(address _evvmAddress) {
        evvmAddress = _evvmAddress;
    }

    /**
     * @notice Deposit ETH or ERC20 tokens with validation
     * @dev For ETH: token must be address(0) and amount must equal msg.value
     *      For ERC20: msg.value must be 0 and amount must be > 0
     * @param token ERC20 token address or address(0) for ETH
     * @param amount Token amount (must match msg.value for ETH deposits)
     */
    function deposit(address token, uint256 amount) external payable {
        if (address(0) == token) {
            // ETH deposit: validate msg.value and amount consistency
            if (msg.value == 0)
                revert ErrorsLib.DepositAmountMustBeGreaterThanZero();

            if (amount != msg.value) revert ErrorsLib.InvalidDepositAmount();

            Evvm(evvmAddress).addAmountToUser(
                msg.sender,
                address(0),
                msg.value
            );
        } else {
            // ERC20 deposit: validate no ETH sent and amount > 0

            if (msg.value != 0) revert ErrorsLib.InvalidDepositAmount();
            if (amount == 0)
                revert ErrorsLib.DepositAmountMustBeGreaterThanZero();

            IERC20(token).transferFrom(msg.sender, address(this), amount);
            Evvm(evvmAddress).addAmountToUser(msg.sender, token, amount);
        }
    }

    /**
     * @notice Withdraw ETH or ERC20 tokens with safety checks
     * @dev Validates principal token protection and sufficient balance before withdrawal
     * @param token Token address (address(0) for ETH)
     * @param amount Amount to withdraw
     */
    function withdraw(address token, uint256 amount) external {
        if (token == Evvm(evvmAddress).getEvvmMetadata().principalTokenAddress)
            revert ErrorsLib.PrincipalTokenIsNotWithdrawable();

        if (Evvm(evvmAddress).getBalance(msg.sender, token) < amount)
            revert ErrorsLib.InsufficientBalance();

        if (token == address(0)) {
            // ETH withdrawal: remove from EVVM balance and transfer safely
            Evvm(evvmAddress).removeAmountFromUser(
                msg.sender,
                address(0),
                amount
            );
            SafeTransferLib.safeTransferETH(msg.sender, amount);
        } else {
            // ERC20 withdrawal: remove from EVVM balance and transfer tokens
            Evvm(evvmAddress).removeAmountFromUser(msg.sender, token, amount);
            IERC20(token).transfer(msg.sender, amount);
        }
    }
}

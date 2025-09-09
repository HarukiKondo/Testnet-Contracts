// SPDX-License-Identifier: EVVM-NONCOMMERCIAL-1.0
// Full license terms available at: https://www.evvm.org/docs/EVVMNoncommercialLicense

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeTransferLib} from "@solady/utils/SafeTransferLib.sol";
import {Evvm} from "@EVVM/testnet/contracts/evvm/Evvm.sol";
import {ErrorsLib} from "@EVVM/testnet/contracts/treasury/lib/ErrorsLib.sol";

contract Treasury {
    address public evvmAddress;

    mapping(address user => uint256 nonce) nextFisherWithdrawalNonce;

    constructor(address _evvmAddress) {
        evvmAddress = _evvmAddress;
    }
    
    function deposit(address token, uint256 amount) external payable {
        if (msg.value > 0) {
            /// user is sending host native coin
            Evvm(evvmAddress).addAmountToUser(
                msg.sender,
                address(0),
                msg.value
            );
        } else {
            /// user is sending ERC20 tokens
            IERC20(token).transferFrom(msg.sender, address(this), amount);
            Evvm(evvmAddress).addAmountToUser(msg.sender, token, amount);
        }
    }

    function withdraw(address token, uint256 amount) external {
        if (Evvm(evvmAddress).getBalance(msg.sender, token) < amount)
            revert ErrorsLib.InsufficientBalance();

        if (token == Evvm(evvmAddress).getEvvmMetadata().principalTokenAddress)
            revert ErrorsLib.PrincipalTokenIsNotWithdrawable();

        if (token == address(0)) {
            /// user is trying to withdraw native coin

            Evvm(evvmAddress).removeAmountFromUser(
                msg.sender,
                address(0),
                amount
            );
            SafeTransferLib.safeTransferETH(msg.sender, amount);
        } else {
            /// user is trying to withdraw ERC20 tokens

            Evvm(evvmAddress).removeAmountFromUser(msg.sender, token, amount);
            IERC20(token).transfer(msg.sender, amount);
        }
    }
}

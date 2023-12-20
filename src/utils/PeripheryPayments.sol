// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IWETH9} from "../interfaces/IWETH9.sol";

abstract contract PeripheryPayments {
    IWETH9 public immutable WETH9;

    constructor(IWETH9 _WETH9) {
        WETH9 = _WETH9;
    }

    receive() external payable {}

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    function approve(IERC20 token, address to, uint256 amount) public payable {
        SafeERC20.safeIncreaseAllowance(token, to, amount);
    }

    function unwrapWETH9(uint256 amountMinimum, address recipient) public payable {
        uint256 balanceWETH9 = WETH9.balanceOf(address(this));
        require(balanceWETH9 >= amountMinimum, "Insufficient WETH9");

        if (balanceWETH9 > 0) {
            WETH9.withdraw(balanceWETH9);
            safeTransferETH(recipient, balanceWETH9);
        }
    }

    function wrapWETH9() public payable {
        if (address(this).balance > 0) WETH9.deposit{value: address(this).balance}(); // wrap everything
    }

    function pullToken(IERC20 token, uint256 amount, address recipient) public payable {
        SafeERC20.safeTransferFrom(token, msg.sender, recipient, amount);
    }

    function sweepToken(IERC20 token, uint256 amountMinimum, address recipient) public payable {
        uint256 balanceToken = token.balanceOf(address(this));
        require(balanceToken >= amountMinimum, "Insufficient token");

        if (balanceToken > 0) {
            SafeERC20.safeTransfer(token, recipient, balanceToken);
        }
    }

    function refundETH() external payable {
        if (address(this).balance > 0) {
            safeTransferETH(msg.sender, address(this).balance);
        }
    }
}

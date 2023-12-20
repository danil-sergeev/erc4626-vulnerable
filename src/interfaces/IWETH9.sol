// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

abstract contract IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable virtual;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external virtual;
}

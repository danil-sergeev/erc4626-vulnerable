// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

interface ISwapper {
    function previewSwap(IERC20 assetFrom, IERC20 assetTo, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function swap(IERC20 assetFrom, IERC20 assetTo, uint256 amountIn, uint256 minAmountOut)
        external
        returns (uint256 amountOut);
}

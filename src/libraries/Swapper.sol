// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {IERC4626} from "@openzeppelin/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ISwapper} from "../interfaces/ISwapper.sol";

/// @title Swapper
/// @notice Abstract base contract for deploying wrappers for AMMs
/// @dev
abstract contract Swapper is ISwapper {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /// @notice Emitted when a new swap has been executed
    /// @param from The base asset
    /// @param to The quote asset
    /// @param amountIn amount that has been swapped
    /// @param amountOut received amount
    event Swap(address indexed sender, IERC20 indexed from, IERC20 indexed to, uint256 amountIn, uint256 amountOut);

    function previewSwap(IERC20 assetFrom, IERC20 assetTo, uint256 amountIn)
        public
        view
        virtual
        returns (uint256 amountOut);

    function swap(IERC20 assetFrom, IERC20 assetTo, uint256 amountIn, uint256 minAmountOut)
        public
        virtual
        returns (uint256 amountOut);
}

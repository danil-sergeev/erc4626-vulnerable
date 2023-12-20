// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {ERC4626} from "./ERC4626.sol";

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {FeesExt} from "../extensions/FeesExt.sol";
import "../interfaces/IFeesController.sol";

abstract contract ERC4626Owned is ERC4626, FeesExt, Ownable {
    /// @notice Maximum deposit limit
    uint256 public depositLimit = 1e27;
    /// @notice if emergencyMode is true, user can only withdraw assets
    bool public emergencyMode = false;

    event DepositLimitUpdated(uint256 depositLimit);
    event EmergencyUpdated(bool value);
    event Sweep(address token, address receiver, uint256 amount);

    constructor(
        IERC20 asset_,
        string memory _name,
        string memory _symbol,
        IFeesController feesController_,
        address admin_
    ) ERC4626(ERC20(address(asset_)), _name, _symbol) FeesExt(feesController_) Ownable(admin_) {}

    function setEmergency(bool emergencyMode_) public onlyOwner {
        emergencyMode = emergencyMode_;

        emit EmergencyUpdated(emergencyMode);
    }

    function setDepositLimit(uint256 depositLimit_) public onlyOwner {
        require(depositLimit_ >= totalAssets());
        depositLimit = depositLimit_;

        emit DepositLimitUpdated(depositLimit);
    }

    function setFeesController(IFeesController feesController_) public onlyOwner {
        Fees__setFeesController(feesController_);
    }

    function sweep(address tokenAddress, address receiver, uint256 amount) external onlyOwner {
        require(tokenAddress != address(asset), "Cannot withdraw the underlying token");
        IERC20(tokenAddress).transfer(receiver, amount);

        emit Sweep(tokenAddress, receiver, amount);
    }

    function sweepETH(address payable receiver, uint256 amount) external payable onlyOwner {
        (bool s,) = receiver.call{value: amount}("");
        require(s, "ETH transfer failed");

        emit Sweep(address(0), receiver, amount);
    }

    function maxDeposit(address) public view virtual override returns (uint256) {
        if (depositLimit >= totalAssets() && !emergencyMode) {
            return depositLimit - totalAssets();
        } else {
            return 0;
        }
    }

    function maxMint(address) public view virtual override returns (uint256) {
        if (depositLimit >= totalAssets() && !emergencyMode) {
            return convertToShares(depositLimit - totalAssets());
        } else {
            return 0;
        }
    }
}

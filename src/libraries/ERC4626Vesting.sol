// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {ERC4626Owned} from "./ERC4626Owned.sol";
import {VestingExt} from "../extensions/VestingExt.sol";
import "./FeesController.sol";

abstract contract ERC4626Vesting is ERC4626Owned, VestingExt {
    event LockPeriodUpdated(uint256 newLockPeriod);

    constructor(
        IERC20 asset_,
        string memory _name,
        string memory _symbol,
        IFeesController feesController_,
        address admin_
    ) ERC4626Owned(asset_, _name, _symbol, feesController_, admin_) {}

    function setLockPeriod(uint256 _lockPeriod) public onlyOwner {
        lockPeriod = _lockPeriod;

        emit LockPeriodUpdated(lockPeriod);
    }

    /////////////////

    function totalAssets() public view override returns (uint256) {
        return Vesting__totalAssets();
    }

    function Vesting__totalLiquidity() internal view virtual override returns (uint256 assets) {
        return _totalFunds();
    }

    function beforeWithdraw(uint256 amount, uint256 shares) internal virtual override returns (uint256 assets) {
        assets = super.beforeWithdraw(amount, shares);

        Vesting__decreaseStoredAssets(assets);
    }

    function afterDeposit(uint256 amount, uint256 shares) internal virtual override {
        Vesting__increaseStoredAssets(amount);

        super.afterDeposit(amount, shares);
    }

    ////////////////

    function _totalFunds() internal view virtual returns (uint256 assets);
}

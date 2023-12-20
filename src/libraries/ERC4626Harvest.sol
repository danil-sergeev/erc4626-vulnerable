// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IERC4626} from "@openzeppelin/interfaces/IERC4626.sol";
import "./ERC4626Vesting.sol";
import "./Swapper.sol";
import "../extensions/HarvestExt.sol";

abstract contract ERC4626Harvest is ERC4626Vesting, HarvestExt {
    event SwapperUpdated(address newSwapper);
    event KeeperUpdated(address newKeeper);

    constructor(
        IERC20 asset_,
        string memory _name,
        string memory _symbol,
        ISwapper swapper_,
        IFeesController feesController_,
        address admin_
    ) ERC4626Vesting(asset_, _name, _symbol, feesController_, admin_) HarvestExt(admin_, swapper_) {}

    function expectedReturns(uint256 timestamp) public view override returns (uint256) {
        return super.expectedReturns(timestamp);
    }

    function harvest(IERC20 reward) public override returns (uint256) {
        return super.harvest(reward);
    }

    function tend() public override returns (uint256, uint256) {
        return super.tend();
    }

    function swap(IERC20 assetFrom, IERC20 assetTo, uint256 amountIn, uint256 minAmountOut)
        public
        override
        returns (uint256)
    {
        return super.swap(assetFrom, assetTo, amountIn, minAmountOut);
    }

    function setKeeper(address account) public onlyOwner {
        keeper = account;

        emit KeeperUpdated(account);
    }

    function setSwapper(ISwapper nextSwapper) public onlyOwner {
        swapper = nextSwapper;

        emit SwapperUpdated(address(swapper));
    }
}

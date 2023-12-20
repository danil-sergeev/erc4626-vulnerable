// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {ERC4626Harvest} from "./ERC4626Harvest.sol";
import {IERC4626} from "@openzeppelin/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract Harvester is Ownable {
    struct HarvestRequest {
        address vault;
        address reward;
        uint256 minAmountOut;
    }

    struct HarvestResponse {
        uint256 rewardAmount;
        uint256 wantAmount;
        uint256 feesAmount;
    }

    constructor(address admin_) Ownable(admin_) {}

    function harvestTend(HarvestRequest memory payload) public onlyOwner returns (HarvestResponse memory response) {
        ERC4626Harvest _vault = ERC4626Harvest(payload.vault);
        address asset = IERC4626(payload.vault).asset();

        uint256 rewardAmount = _vault.harvest(IERC20(payload.reward));
        _vault.swap(IERC20(payload.reward), IERC20(asset), rewardAmount, payload.minAmountOut);
        (uint256 wantAmount, uint256 feesAmount) = _vault.tend();

        response.rewardAmount = rewardAmount;
        response.wantAmount = wantAmount;
        response.feesAmount = feesAmount;
    }

    function multiHarvestTend(HarvestRequest[] calldata payload)
        public
        onlyOwner
        returns (HarvestResponse[] memory responses)
    {
        responses = new HarvestResponse[](payload.length);

        for (uint32 i = 0; i < payload.length; i++) {
            HarvestResponse memory response = harvestTend(payload[i]);
            responses[i] = response;
        }
    }
}

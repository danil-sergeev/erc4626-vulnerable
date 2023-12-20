// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {StargateVault} from "./StargateVault.sol";
import {ERC4626Factory} from "./libraries/ERC4626Factory.sol";
import {ERC4626} from "./libraries/ERC4626.sol";
import {FeesController} from "./libraries/FeesController.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import "./interfaces/external/IStargateLPStaking.sol";
import "./interfaces/external/IStargateRouter.sol";
import "./interfaces/external/IStargatePool.sol";
import "./interfaces/external/IStargateFactory.sol";
import "./interfaces/IFeesController.sol";
import "./interfaces/ISwapper.sol";

/// @title StargateVaultFactory
/// @notice Factory for creating StargateVault contracts
contract StargateVaultFactory is ERC4626Factory {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error StargateVaultFactory__PoolNonexistent();
    error StargateVaultFactory__StakingNonexistent();
    error StargateVaultFactory__Deprecated();

    /// @notice The stargate pool factory contract
    IStargateFactory public immutable stargateFactory;
    /// @notice The stargate bridge router contract
    IStargateRouter public immutable stargateRouter;
    /// @notice The stargate lp staking contract
    IStargateLPStaking public immutable stargateLPStaking;
    /// @notice Swapper contract
    ISwapper public immutable swapper;
    /// @notice fees controller
    FeesController public immutable feesController;

    address public admin;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        IStargateFactory factory_,
        IStargateRouter router_,
        IStargateLPStaking staking_,
        FeesController feesController_,
        ISwapper swapper_,
        address admin_
    ) {
        stargateFactory = factory_;
        stargateRouter = router_;
        stargateLPStaking = staking_;
        swapper = swapper_;
        feesController = feesController_;
        admin = admin_;
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------
    function createERC4626(IERC20 asset, uint256 poolId, uint256 stakingId) external returns (ERC4626 vault) {
        IStargatePool pool = stargateFactory.getPool(poolId);
        require(address(asset) == pool.token(), "Error: invalid asset");

        IERC20 lpToken = IERC20(address(pool));

        if (lpToken != stargateLPStaking.poolInfo(stakingId).lpToken) {
            revert StargateVaultFactory__StakingNonexistent();
        }

        vault = new StargateVault{salt: bytes32(0)}(
            asset, pool, stargateRouter, stargateLPStaking, stakingId, swapper, feesController, admin
        );

        emit CreateERC4626(ERC20(address(asset)), vault);
    }

    function computeERC4626Address(IERC20 asset, uint256 poolId, uint256 stakingId)
        external
        view
        returns (ERC4626 vault)
    {
        IStargatePool pool = stargateFactory.getPool(poolId);

        require(asset == IERC20(pool.token()), "Error: invalid asset");

        IERC20 lpToken = IERC20(address(pool));

        if (lpToken != stargateLPStaking.poolInfo(stakingId).lpToken) {
            revert StargateVaultFactory__StakingNonexistent();
        }

        vault = ERC4626(
            computeCreate2Address(
                keccak256(
                    abi.encodePacked(
                        // Deployment bytecode:
                        type(StargateVault).creationCode,
                        // Constructor arguments:
                        abi.encode(
                            asset, pool, stargateRouter, stargateLPStaking, stakingId, swapper, feesController, admin
                        )
                    )
                )
            )
        );
    }
}

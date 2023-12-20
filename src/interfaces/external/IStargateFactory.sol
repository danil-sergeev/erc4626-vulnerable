// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import "./IStargatePool.sol";

interface IStargateFactory {
    function getPool(uint256) external view returns (IStargatePool);
}

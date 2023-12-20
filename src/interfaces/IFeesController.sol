// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

interface IFeesController {
    event TreasuryUpdated(address nextTreasury);
    event FallbackTreasuryUpdated(address nextTreasury);
    event FeesUpdated(address indexed vault, string feeType, uint24 value);
    event FeesCollected(address indexed vault, string feeType, uint256 feeAmount, address asset);

    function feesCollected(address vault, string memory feeType) external view returns (uint256);

    function getFeeBps(address vault, string memory feeType) external view returns (uint24 feeBps);

    function setFeeBps(address vault, string memory feeType, uint24 value) external;

    function previewFee(uint256 amount, string memory feeType)
        external
        view
        returns (uint256 feesAmount, uint256 restAmount);

    function collectFee(uint256 amount, string memory feeType)
        external
        returns (uint256 feesAmount, uint256 restAmount);
}

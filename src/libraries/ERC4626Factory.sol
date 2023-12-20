// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {ERC4626} from "./ERC4626.sol";
import {Address} from "@openzeppelin/utils/Address.sol";

/// @title ERC4626Factory
/// @notice Abstract base contract for deploying ERC4626 wrappers
/// @dev Uses CREATE2 deterministic deployment, so there can only be a single
/// vault for each asset.
abstract contract ERC4626Factory {
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------

    using Address for address;

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /// @notice Emitted when a new ERC4626 vault has been created
    /// @param asset The base asset used by the vault
    /// @param vault The vault that was created
    event CreateERC4626(ERC20 indexed asset, ERC4626 vault);

    /// -----------------------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------------------

    /// @notice Computes the address of a contract deployed by this factory using CREATE2, given
    /// the bytecode hash of the contract. Can also be used to predict addresses of contracts yet to
    /// be deployed.
    /// @dev Always uses bytes32(0) as the salt
    /// @param bytecodeHash The keccak256 hash of the creation code of the contract being deployed concatenated
    /// with the ABI-encoded constructor arguments.
    /// @return The address of the deployed contract
    function computeCreate2Address(bytes32 bytecodeHash) internal view virtual returns (address) {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xFF), address(this), bytes32(0), bytecodeHash))))
        );
    }
}

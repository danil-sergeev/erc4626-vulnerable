// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.22;

import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC20Permit} from "./ERC20Permit.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {IERC20Metadata} from "@openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

/// @notice Minimal ERC4626 tokenized Vault implementation.
/// @dev modified withdraw() and redeem() methods, add beforeWithdraw ability to change assets amount
abstract contract ERC4626 is ERC20 {
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );
    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */

    error ERC4626ExceededMaxDeposit(address receiver, uint256 assets, uint256 max);

    /**
     * @dev Attempted to mint more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxMint(address receiver, uint256 shares, uint256 max);

    /**
     * @dev Attempted to withdraw more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxWithdraw(address owner, uint256 assets, uint256 max);

    /**
     * @dev Attempted to redeem more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);

    ERC20 public immutable asset;
    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;
    uint8 private immutable _underlyingDecimals;

    constructor(ERC20 asset_, string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        asset_ = asset_;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        //  'dead shares' technique used by UniswapV2
        if (totalSupply() == 0) {
            _mint(address(0), MINIMUM_LIQUIDITY);
            shares -= MINIMUM_LIQUIDITY;
        }

        _mint(receiver, shares);
        SafeERC20.safeTransferFrom(asset, msg.sender, address(this), assets);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }
        assets = previewMint(shares);

        _mint(receiver, shares);
        SafeERC20.safeTransferFrom(asset, msg.sender, address(this), assets);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256 shares) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        shares = previewWithdraw(assets);

        if (_msgSender() != owner) {
            _spendAllowance(owner, _msgSender(), shares);
        }

        assets = beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(_msgSender(), receiver, owner, assets, shares);

        SafeERC20.safeTransfer(asset, receiver, assets);
    }

    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256 assets) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        if (_msgSender() != owner) {
            _spendAllowance(owner, _msgSender(), shares);
        }

        assets = beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        SafeERC20.safeTransfer(asset, receiver, assets);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual returns (uint256);

    function convertToShares(uint256 assets) public view returns (uint256) {
        if (totalAssets() == 0) {
            return assets;
        }
        return totalSupply() * assets / totalAssets();
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        return totalAssets() * shares / totalSupply();
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual returns (uint256 asssets) {
        return assets;
    }

    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}

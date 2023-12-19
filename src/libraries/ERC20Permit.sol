// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {EIP712} from "@openzeppelin/utils/cryptography/EIP712.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";
import {Nonces} from "./Nonces.sol";

abstract contract ERC20Permit is ERC20, EIP712, Nonces {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) EIP712(name, "1") {}

    function permit(
        address owner,
        address spender,
        uint256 nonce,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        _useUnorderedNonce(owner, nonce);
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}

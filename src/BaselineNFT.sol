// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MinimalERC721.sol";

/// @notice Naive cross-chain NFT baseline.
/// bridgeOut emits a bridge event but does not mark the token as pending,
/// so ownership-dependent operations remain available before finalization.
contract BaselineNFT is MinimalERC721 {
    mapping(uint256 => bool) public listed;

    event BridgeOut(uint256 indexed tokenId, uint256 indexed dstChainId, address indexed owner);
    event FinalizeIn(uint256 indexed tokenId, uint256 indexed srcChainId, bytes32 indexed messageId, address owner);
    event Listed(uint256 indexed tokenId, address indexed owner);

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function bridgeOut(uint256 tokenId, uint256 dstChainId) external {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) revert NotOwnerOrApproved();
        emit BridgeOut(tokenId, dstChainId, ownerOf(tokenId));
    }

    function finalizeIn(uint256 tokenId, address newOwner, uint256 srcChainId, bytes32 messageId) external {
        _forceOwner(newOwner, tokenId);
        emit FinalizeIn(tokenId, srcChainId, messageId, newOwner);
    }

    function canList(uint256) external pure returns (bool) {
        return true;
    }

    function list(uint256 tokenId) external {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) revert NotOwnerOrApproved();
        listed[tokenId] = true;
        emit Listed(tokenId, ownerOf(tokenId));
    }
}

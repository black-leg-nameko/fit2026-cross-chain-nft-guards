// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBridgeAwareNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function canList(uint256 tokenId) external view returns (bool);
}

/// @notice Minimal marketplace used to model listing as an ownership-dependent
/// operation. It rejects listings when the NFT reports that the token is pending.
contract MockMarketplace {
    error NotOwnerOrApproved();
    error ListingRejectedByTokenState();

    struct Listing {
        address seller;
        bool active;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    event Listed(address indexed nft, uint256 indexed tokenId, address indexed seller);

    function list(address nftAddress, uint256 tokenId) external {
        IBridgeAwareNFT nft = IBridgeAwareNFT(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (
            msg.sender != owner
                && nft.getApproved(tokenId) != msg.sender
                && !nft.isApprovedForAll(owner, msg.sender)
        ) {
            revert NotOwnerOrApproved();
        }
        if (!nft.canList(tokenId)) revert ListingRejectedByTokenState();

        listings[nftAddress][tokenId] = Listing({seller: owner, active: true});
        emit Listed(nftAddress, tokenId, owner);
    }
}

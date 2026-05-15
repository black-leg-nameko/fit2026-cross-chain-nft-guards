// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Minimal ERC-721-like core used only for the FIT2026 PoC.
/// It intentionally avoids external dependencies so the examples can be
/// compiled with a plain solc binary.
contract MinimalERC721 {
    error NotOwnerOrApproved();
    error TokenAlreadyMinted();
    error TokenNotMinted();
    error TransferToZeroAddress();
    error ApprovalToCurrentOwner();
    error ApproveCallerNotOwnerNorApprovedForAll();

    mapping(uint256 => address) internal _owners;
    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "zero owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) revert TokenNotMinted();
        return owner;
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        if (_owners[tokenId] == address(0)) revert TokenNotMinted();
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function approve(address to, uint256 tokenId) public virtual {
        address owner = ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();
        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) {
            revert ApproveCallerNotOwnerNorApprovedForAll();
        }

        _approve(to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        require(operator != msg.sender, "approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) revert NotOwnerOrApproved();
        _transfer(from, to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        if (to == address(0)) revert TransferToZeroAddress();
        if (_owners[tokenId] != address(0)) revert TokenAlreadyMinted();

        _owners[tokenId] = to;
        _balances[to] += 1;
        emit Transfer(address(0), to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        if (to == address(0)) revert TransferToZeroAddress();
        if (ownerOf(tokenId) != from) revert NotOwnerOrApproved();

        delete _tokenApprovals[tokenId];
        _owners[tokenId] = to;
        _balances[from] -= 1;
        _balances[to] += 1;
        emit Transfer(from, to, tokenId);
    }

    function _forceOwner(address to, uint256 tokenId) internal {
        address oldOwner = _owners[tokenId];
        if (oldOwner == address(0)) {
            _mint(to, tokenId);
            return;
        }
        if (oldOwner != to) {
            delete _tokenApprovals[tokenId];
            _owners[tokenId] = to;
            _balances[oldOwner] -= 1;
            _balances[to] += 1;
            emit Transfer(oldOwner, to, tokenId);
        }
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender);
    }
}

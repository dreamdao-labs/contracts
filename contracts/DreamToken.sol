// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/governance/utils/Votes.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract DreamToken is AccessControl, Pausable, Votes, ERC2981, ERC1155, ERC1155Burnable, ERC1155Supply {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant STAR = 0;
    uint256 public constant MOON = 1;
    uint256 public constant SUN = 2;

    uint256 public constant LEVEL_UP_REQUIRED = 5;

    constructor(string memory uri, address receiver, uint96 fraction) ERC1155(uri) EIP712("DreamToken", "1") {
        _setDefaultRoyalty(receiver, fraction);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());
    }

    function supportsInterface(bytes4 interfaceId) public view override(AccessControl, ERC1155, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setURI(string memory newuri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function setDefaultRoyalty(address recipient, uint96 fraction) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(recipient, fraction);
    }

    function deleteDefaultRoyalty() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _deleteDefaultRoyalty();
    }

    function setTokenRoyalty(uint256 tokenId, address recipient, uint96 fraction) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTokenRoyalty(tokenId, recipient, fraction);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) external onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    function levelUp(uint256 id, uint256 amount) external {
        require(id == STAR || id == MOON, "Invalid id");
        require(amount % LEVEL_UP_REQUIRED == 0, "less than required for level up");

        burn(_msgSender(), id, amount);

        _mint(_msgSender(), id++, amount / LEVEL_UP_REQUIRED, "");
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal whenNotPaused override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _afterTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal override {
        uint256 votes = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            votes += _countVotes(ids[i], amounts[i]);
        }
        _transferVotingUnits(from, to, votes);
        super._afterTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _getVotingUnits(address account) internal view override returns (uint256) {
        uint256 votes = 0;
        for (uint256 i = 0; i < 3; i++) {
            votes += _countVotes(i, balanceOf(account, i));
        }
        return votes;
    }

    function _countVotes(uint256 id, uint256 amount) internal pure returns (uint256) {
        uint256 votes = 0;
        if (id == STAR) {
            votes += amount;
        }
        if (id == MOON) {
            votes += amount * LEVEL_UP_REQUIRED;
        }
        if (id == SUN) {
            votes += amount * LEVEL_UP_REQUIRED ** SUN;
        }
        return votes;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DreamVault is Ownable {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public totalTransferred;

    event Deposited(address indexed token, address indexed account, uint256 amount);
    event Transferred(address indexed token, address indexed account, uint256 amount);

    receive() external payable {
        deposit(address(0), msg.value);
    }

    function balanceOf(address token) public view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20(token).balanceOf(address(this));
    }

    function totalDeposited(address token) public view returns (uint256) {
        return balanceOf(token) + totalTransferred[token];
    }

    function deposit(address token, uint256 amount) public payable {
        require(amount > 0, "Vault::deposit: amount must be greater than 0");

        if (token == address(0)) {
            require(msg.value == amount, "Vault::deposit: value does not match amount");
        } else {
            IERC20(token).safeTransferFrom(_msgSender(), address(this), amount);
        }

        emit Deposited(token, _msgSender(), amount);
    }

    function transfer(address token, address account, uint256 amount) external onlyOwner {
        require(account != address(0), "Vault::transfer: account cannot be zero address");
        require(amount > 0, "Vault::transfer: amount must be greater than 0");

        totalTransferred[token] += amount;

        if (token == address(0)) {
            Address.sendValue(payable(account), amount);
        } else {
            IERC20(token).safeTransfer(account, amount);
        }

        emit Transferred(token, account, amount);
    }
}

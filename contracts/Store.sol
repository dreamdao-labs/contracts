// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IERC1155Mintable {
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
}

contract Store is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant STAR = 0;

    address public immutable nft;

    address public token;
    address public payee;

    uint256 public price = 500e18;
    uint256 public totalSales = 0;

    event TokenUpdated(address previousToken, address newToken);
    event PayeeUpdated(address previousPayee, address newPayee);
    event PriceUpdated(uint256 previousPrice, uint256 newPrice);

    constructor(address nft_, address token_, address payee_) {
        require(nft_ != address(0), "NFT cannot be zero address");
        require(token_ != address(0), "Token cannot be zero address");
        require(payee_ != address(0), "Payee cannot be zero address");

        nft = nft_;
        token = token_;
        payee = payee_;
    }

    function setToken(address newToken) external onlyOwner {
        address previousToken = token;
        token = newToken;
        emit TokenUpdated(previousToken, newToken);
    }

    function setPayee(address payable newPayee) external onlyOwner {
        address previousPayee = payee;
        payee = newPayee;
        emit PayeeUpdated(previousPayee, newPayee);
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        uint256 previousPrice = price;
        price = newPrice;
        emit PriceUpdated(previousPrice, newPrice);
    }

    function purchase(uint256 amount) external nonReentrant {
        uint256 weiAmount = amount * price;
        IERC20(token).safeTransferFrom(_msgSender(), address(this), weiAmount);

        if (IERC165(nft).supportsInterface(type(IERC2981).interfaceId)) {
            (address receiver, uint256 royaltyAmount) = IERC2981(address(nft)).royaltyInfo(0, weiAmount);
            IERC20(token).safeTransfer(receiver, royaltyAmount);
        }

        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(payee, tokenBalance);

        totalSales += amount;

        IERC1155Mintable(nft).mint(_msgSender(), STAR, amount, "");
    }
}

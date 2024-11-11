// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TradeManager is Ownable {
    IUniswapV2Router02 public uniswapRouter;
    address public WBNB;
    mapping(address => bool) public allowedTokens;

    // Account => Token => Amount
    mapping(address => mapping(address => uint256)) public balances;
    uint256 public totalBalance;
    address[] public copyTradeAddresses;

    enum CopyTradeStatus {
        ACTIVE,
        PENDING,
        COMPLETED
    }

    struct CopyTrade {
        address token;
        uint256 amount;
        string userName;
        string leverage;
        string userId;
        uint256 lockPeriod;
        uint256 startDate;
        address userWallet;
        CopyTradeStatus status;
    }

    mapping(address => CopyTrade[]) public copyTrades;
    address public manager;

    // Errors
    error Vault_TokenNotAllowed(address token);
    error Vault_InsufficientBalance();
    error Vault_StrategyNotAllowed();

    event Log(string message);
    event LogAddress(string message, address addr);
    event LogUint(string message, uint256 value);

    // modifiers
    modifier onlyAllowedTokens(address token) {
        if (!allowedTokens[token]) revert Vault_TokenNotAllowed(token);
        _;
    }

    modifier onlyManager() {
        if (msg.sender != manager) revert Vault_StrategyNotAllowed();
        _;
    }

    constructor(address _router, address _wbnb) Ownable(msg.sender) {
        uniswapRouter = IUniswapV2Router02(_router);
        WBNB = _wbnb;
        manager = msg.sender;
    }

    function setManager(address _manager) external onlyOwner {
        manager = _manager;
    }

    function setAllowedToken(address token) external onlyOwner {
        allowedTokens[token] = true;
    }

    function removeAllowedToken(
        address token
    ) external onlyOwner onlyAllowedTokens(token) {
        allowedTokens[token] = false;
    }

    function getBalances(
        address user,
        address token
    ) external view returns (uint256) {
        return balances[user][token];
    }

    function getAllCopyTrades() external view returns (CopyTrade[] memory) {
        uint256 totalTrades = 0;
        for (uint256 i = 0; i < copyTradeAddresses.length; i++) {
            totalTrades += copyTrades[copyTradeAddresses[i]].length;
        }

        CopyTrade[] memory allTrades = new CopyTrade[](totalTrades);
        uint256 index = 0;

        for (uint256 i = 0; i < copyTradeAddresses.length; i++) {
            CopyTrade[] storage trades = copyTrades[copyTradeAddresses[i]];
            for (uint256 j = 0; j < trades.length; j++) {
                allTrades[index] = trades[j];
                index++;
            }
        }

        return allTrades;
    }

    function getCopyTradeAddresses() external view returns (address[] memory) {
        return copyTradeAddresses;
    }

    function getCopyTrades() external view returns (CopyTrade[] memory) {
        uint256 totalTrades = 0;
        for (uint256 i = 0; i < copyTradeAddresses.length; i++) {
            totalTrades += copyTrades[copyTradeAddresses[i]].length;
        }

        CopyTrade[] memory allTrades = new CopyTrade[](totalTrades);
        uint256 index = 0;

        for (uint256 i = 0; i < copyTradeAddresses.length; i++) {
            CopyTrade[] storage trades = copyTrades[copyTradeAddresses[i]];
            for (uint256 j = 0; j < trades.length; j++) {
                allTrades[index] = trades[j];
                index++;
            }
        }

        return allTrades;
    }

    function makeCopyTrade(
        address token,
        uint256 amount,
        string memory userName,
        string memory leverage,
        string memory userId,
        uint256 lockPeriod,
        address userWallet
    ) external onlyAllowedTokens(token) {
        require(amount > 0, "Amount must be greater than 0");

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        balances[msg.sender][token] += amount;
        totalBalance += amount;

        // Create a new copy trade
        copyTrades[msg.sender].push(
            CopyTrade(
                token,
                amount,
                userName,
                leverage,
                userId,
                lockPeriod,
                block.timestamp,
                userWallet,
                CopyTradeStatus.PENDING
            )
        );

        // Add user to copyTradeAddresses if not already present
        if (copyTrades[msg.sender].length == 1) {
            copyTradeAddresses.push(msg.sender);
        }
    }

    function withdraw(
        address token,
        address to,
        uint256 amount,
        string memory leverage
    ) external {
        if (totalBalance < amount) revert Vault_InsufficientBalance();

        // get copy trades by leverage
        for (uint256 i = 0; i < copyTrades[msg.sender].length; i++) {
            if (
                keccak256(
                    abi.encodePacked(copyTrades[msg.sender][i].leverage)
                ) == keccak256(abi.encodePacked(leverage))
            ) {
                // update the status of the copy trade
                copyTrades[msg.sender][i].status = CopyTradeStatus.ACTIVE;
            }
        }
        // transfer the amounts after you have updated the copy traders status
        IERC20(token).transfer(to, amount);
        totalBalance -= amount;
    }

    // helper functions to swap tokens
    function swapTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external {
        require(_amountIn > 0, "AmountIn must be greater than 0");

        emit Log("Starting transferFrom");
        bool successTransfer = IERC20(_tokenIn).transferFrom(
            msg.sender,
            address(this),
            _amountIn
        );
        require(successTransfer, "TransferFrom failed");
        emit Log("TransferFrom completed");

        emit Log("Starting approve");
        bool successApprove = IERC20(_tokenIn).approve(
            address(uniswapRouter),
            type(uint256).max
        );

        require(successApprove, "Approve failed");
        emit Log("Approve completed");

        uint256 _deadline = block.timestamp + 1 minutes;

        address[] memory path;
        if (_tokenIn == WBNB || _tokenOut == WBNB) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WBNB;
            path[2] = _tokenOut;
        }
        emit Log(
            "Starting swapExactTokensForTokensSupportingFeeOnTransferTokens"
        );
        try
            uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amountIn,
                0,
                path,
                msg.sender,
                _deadline
            )
        {
            emit Log("Swap completed successfully");
        } catch Error(string memory reason) {
            emit Log(reason);
            revert("Swap failed");
        } catch (bytes memory /* lowLevelData */) {
            emit Log("Swap failed with low-level error");
            revert("Swap failed");
        }
    }
}

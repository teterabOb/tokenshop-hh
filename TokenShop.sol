// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface TokenInterface{
    function mint(address account, uint256 amount) external returns(bool);
}

contract TokenShop {
    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;
    uint256 public tokenPrice = 200; // 1 token = 2.00 usd, with 2 decimals
    address public owner;

    constructor(address tokenAddress){
        minter = TokenInterface(tokenAddress);
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
    }
    
    // Return the latest price
    function getLatestPrice() public view returns(int){
        (
            /* uint80 roundId */ , 
            int price, 
            /* uint256 startedAt */,
            /* uint256 updatedAt */,            
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();

        return price;
    }

    function tokenAmount(uint256 amountETH) public view returns(uint256){
        uint256 ethUsd = uint256(getLatestPrice());
        uint256 amountUSD = amountETH * ethUsd / 10**18; // ETH = 18 decimal places
        uint256 amountToken = amountUSD / tokenPrice / 10000; // To keep decimal places
        return amountToken;
    }

    receive() external payable{
        uint256 amountToken = tokenAmount(msg.value);
        minter.mint(msg.sender, amountToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}


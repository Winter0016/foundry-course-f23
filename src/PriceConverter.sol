// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// Why not an interface?
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // We could make this public, but then we'd have to deploy it
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Sepolia ETH / USD Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses

        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit //when you call latesrounddata they will return in 8 decimals like if 1eth = 2000 dollars they will return 200000000000 dollars instead
        return uint256(answer / 1e8);
    }

    // 1000000000
    function getConversionRate(
        uint256 ethAmount, //when you put as eth machine will automatically convert it into wei
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice *ethAmount) / 1e18;
        // ethPrice * (ethAmount / 1e18) will not work why because solidity does not accept float number like 0.003 when you convert wei to eth if the result is less than 1 which is 0.003 eth for example it will return 0 instead. BE CAUTION ABOUT THIS!
        return ethAmountInUsd; // this will return USD
    }
}

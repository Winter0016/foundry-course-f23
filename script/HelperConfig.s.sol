// 1. deploy mocks when we are on a local anvil chain
//2 . keep track of contrac address across different chains
// Sepolia ETH/USD
// Mainet ETH/USD

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks
    // Otherwise, grab the existing address from the live network
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getsepoliaEthconfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getmainEthconfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getsepoliaEthconfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaconfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        // you could do like this:
        // NetworkConfig memory sepoliaconfig = NetworkConfig(0x8C9C95A830b7E7e86f2f12DB88e911499A6f695f);
        // it's the same to the one above.why? because in struct there is only 1 variable, it will automatically know but if it's more than two you have to do like the one above.

        return sepoliaconfig;
    }

    function getmainEthconfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethconfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethconfig;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // price feed address
        //1. deploy mocks
        //2. return the mock address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();

        MockV3Aggregator mockpriceFeed = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockpriceFeed)
        });
        return anvilConfig;
    }
}

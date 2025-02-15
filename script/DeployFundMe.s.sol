// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract Deploy is Script {
    function run() external returns (FundMe) {
        // Before startbroadcast --> not a "real" tx
        HelperConfig helperconfig = new HelperConfig();
        address ethUsdPricefeed = helperconfig.activeNetworkConfig();
        // after startBroadcast -> real tx!
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPricefeed);
        vm.stopBroadcast();
        return fundMe;
    }
}

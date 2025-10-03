// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Script} from "forge-std/Script.sol";
import {TwapResponse} from "../src/TwapResponse.sol";

contract DeployTwapResponse is Script {
    function run() external returns (TwapResponse) {
        vm.startBroadcast();
        TwapResponse twapResponse = new TwapResponse();
        vm.stopBroadcast();
        return twapResponse;
    }
}

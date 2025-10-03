// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Test} from "forge-std/Test.sol";
import {TwapOracleTrap} from "../src/TwapOracleTrap.sol";
import {MockAggregatorV3} from "./mocks/MockAggregatorV3.sol";

contract TwapOracleTrapTest is Test, TwapOracleTrap {
    MockAggregatorV3 internal mockPriceFeed;

    function setUp() public {
        mockPriceFeed = new MockAggregatorV3(2000e8);
        _setPriceFeed(address(mockPriceFeed));
    }

    function test_ShouldRespond_When_PriceDeviatesAboveThreshold() public {
        // 1. Setup data
        bytes[] memory data = new bytes[](2);
        
        // First collect, price is 2000
        mockPriceFeed.setLatestPrice(2000e8);
        data[0] = collect();

        // Second collect, price is 2100 (5% deviation)
        mockPriceFeed.setLatestPrice(2100e8);
        data[1] = collect();

        // 2. Call shouldRespond
        (bool should, bytes memory response) = shouldRespond(data);

        // 3. Assert
        assertTrue(should, "should be true");
        (int256 latestPrice, int256 twap) = abi.decode(response, (int256, int256));
        assertEq(latestPrice, 2100e8, "latestPrice should be 2100e8");
        assertEq(twap, 2050e8, "twap should be 2050e8");
    }

    function test_ShouldNotRespond_When_PriceDeviatesBelowThreshold() public {
        // 1. Setup data
        bytes[] memory data = new bytes[](2);
        
        // First collect, price is 2000
        mockPriceFeed.setLatestPrice(2000e8);
        data[0] = collect();

        // Second collect, price is 2001 (0.05% deviation)
        mockPriceFeed.setLatestPrice(2001e8);
        data[1] = collect();

        // 2. Call shouldRespond
        (bool should, ) = shouldRespond(data);

        // 3. Assert
        assertFalse(should, "should be false");
    }
}
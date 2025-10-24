// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Test} from "forge-std/Test.sol";
import {TwapOracleTrap, CollectOutput} from "../src/TwapOracleTrap.sol";
import {MockAggregatorV3} from "./mocks/MockAggregatorV3.sol";

contract TwapOracleTrapTest is Test {
    TwapOracleTrap internal trap;
    MockAggregatorV3 internal mockPriceFeed;

    function setUp() public {
        trap = new TwapOracleTrap();
        mockPriceFeed = new MockAggregatorV3(2000e8);
    }

    function test_ShouldRespond_When_PriceDeviatesAboveThreshold() public {
        // 1. Setup data
        bytes[] memory data = new bytes[](2);
        
        // Latest data point (data[0])
        mockPriceFeed.setLatestPrice(2100e8);
        data[0] = abi.encode(CollectOutput({price: 2100e8, timestamp: block.timestamp, collectedAt: block.timestamp}));

        // Older data point (data[1])
        mockPriceFeed.setLatestPrice(2000e8);
        data[1] = abi.encode(CollectOutput({price: 2000e8, timestamp: block.timestamp, collectedAt: block.timestamp}));

        // 2. Call shouldRespond
        (bool should, bytes memory response) = trap.shouldRespond(data);

        // 3. Assert
        assertTrue(should, "should be true");
        (uint256 latestPrice, uint256 twap) = abi.decode(response, (uint256, uint256));
        assertEq(latestPrice, 2100e8, "latestPrice should be 2100e8");
        assertEq(twap, 2050e8, "twap should be 2050e8");
    }

    function test_ShouldNotRespond_When_PriceDeviatesBelowThreshold() public {
        // 1. Setup data
        bytes[] memory data = new bytes[](2);
        
        // Latest data point (data[0])
        mockPriceFeed.setLatestPrice(2001e8);
        data[0] = abi.encode(CollectOutput({price: 2001e8, timestamp: block.timestamp, collectedAt: block.timestamp}));

        // Older data point (data[1])
        mockPriceFeed.setLatestPrice(2000e8);
        data[1] = abi.encode(CollectOutput({price: 2000e8, timestamp: block.timestamp, collectedAt: block.timestamp}));

        // 2. Call shouldRespond
        (bool should, ) = trap.shouldRespond(data);

        // 3. Assert
        assertFalse(should, "should be false");
    }

    function test_ShouldNotRespond_When_DataIsStale() public {
        // 1. Setup data
        bytes[] memory data = new bytes[](2);
        
        vm.warp(1_000_000);

        // Latest data point (data[0]) - stale
        data[0] = abi.encode(CollectOutput({price: 2100e8, timestamp: block.timestamp - 4000, collectedAt: block.timestamp}));

        // Older data point (data[1])
        data[1] = abi.encode(CollectOutput({price: 2000e8, timestamp: block.timestamp - 4000, collectedAt: block.timestamp}));

        // 2. Call shouldRespond
        (bool should, ) = trap.shouldRespond(data);

        // 3. Assert
        assertFalse(should, "should be false due to stale data");
    }
}
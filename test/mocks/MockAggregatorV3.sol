// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockAggregatorV3 is AggregatorV3Interface {
    int256 private _latestPrice;

    constructor(int256 initialPrice) {
        _latestPrice = initialPrice;
    }

    function setLatestPrice(int256 latestPrice) public {
        _latestPrice = latestPrice;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (1, _latestPrice, block.timestamp, block.timestamp, 1);
    }

    function decimals() external pure returns (uint8) {
        return 8;
    }

    function description() external pure returns (string memory) {
        return "Mock Aggregator V3";
    }

    function version() external pure returns (uint256) {
        return 1;
    }

    function getRoundData(
        uint80 /*_roundId*/
    ) external view returns (uint80, int256, uint256, uint256, uint80) {
        return (1, _latestPrice, block.timestamp, block.timestamp, 1);
    }
}

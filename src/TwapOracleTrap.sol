// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

struct CollectOutput {
    int256 price;
    uint256 timestamp;
    uint256 collectedAt;
}

contract TwapOracleTrap is ITrap {
    // @notice The Chainlink price feed to monitor.
    AggregatorV3Interface internal constant PRICE_FEED = AggregatorV3Interface(0x5f4ec3dF9CBD43714fe274045f36413d85b6083f); // ETH/USD

    // @notice The percentage deviation from the TWAP that will trigger a response.
    // @dev 100 = 1%
    uint256 internal constant DEVIATION_THRESHOLD = 100; // 1%

    // @notice The maximum age of a price feed sample in seconds.
    uint256 internal constant STALENESS_THRESHOLD = 3600; // 1 hour

    function collect() external view override returns (bytes memory) {
        (, int256 price, , uint256 timestamp, ) = PRICE_FEED.latestRoundData();
        return abi.encode(CollectOutput({price: price, timestamp: timestamp, collectedAt: block.timestamp}));
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        if (data.length < 2 || data[0].length == 0 || data[1].length == 0) {
            return (false, "");
        }

        CollectOutput memory latestOutput = abi.decode(data[0], (CollectOutput));

        if (
            latestOutput.timestamp == 0 ||
            latestOutput.collectedAt < latestOutput.timestamp
        ) {
            return (false, "");
        }
        if (latestOutput.collectedAt - latestOutput.timestamp > STALENESS_THRESHOLD) {
            return (false, "");
        }
        if (latestOutput.price <= 0) {
            return (false, "");
        }

        int256 totalPrice = 0;
        uint256 validSamples = 0;
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i].length == 0) continue;
            CollectOutput memory o = abi.decode(data[i], (CollectOutput));
            if (o.timestamp == 0 || o.collectedAt < o.timestamp) continue;
            if (o.collectedAt - o.timestamp > STALENESS_THRESHOLD) continue;
            if (o.price <= 0) continue;
            totalPrice += o.price;
            validSamples++;
        }

        if (validSamples < 2) {
            return (false, "");
        }

        int256 twap = totalPrice / int256(validSamples);
        if (twap <= 0) {
            return (false, "");
        }
        
        int256 latestPrice = latestOutput.price;

        int256 priceDiff = latestPrice > twap
            ? latestPrice - twap
            : twap - latestPrice;

        if (
            (uint256(priceDiff) * 10000) / uint256(twap) > DEVIATION_THRESHOLD
        ) {
            return (true, abi.encode(uint256(latestPrice), uint256(twap)));
        }

        return (false, "");
    }
}

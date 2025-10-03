// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

struct CollectOutput {
    int256 price;
}

contract TwapOracleTrap is ITrap {
    // @notice The Chainlink price feed to monitor.
    // @dev This is a placeholder and should be replaced with a real price feed address on Hoodi.
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0x5f4ec3dF9CBD43714fe274045f36413d85b6083f); // ETH/USD

    function _setPriceFeed(address newPriceFeed) internal {
        priceFeed = AggregatorV3Interface(newPriceFeed);
    }

    // @notice The percentage deviation from the TWAP that will trigger a response.
    // @dev 100 = 1%
    uint256 internal constant DEVIATION_THRESHOLD = 100; // 1%

    function collect() public view returns (bytes memory) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return abi.encode(CollectOutput({price: price}));
    }

    function shouldRespond(
        bytes[] memory data
    ) public pure returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, "");
        }

        int256 totalPrice = 0;
        for (uint256 i = 0; i < data.length; i++) {
            CollectOutput memory output = abi.decode(data[i], (CollectOutput));
            totalPrice += output.price;
        }

        int256 twap = totalPrice / int256(data.length);
        
        CollectOutput memory latestOutput = abi.decode(
            data[data.length - 1],
            (CollectOutput)
        );
        int256 latestPrice = latestOutput.price;

        int256 priceDiff = latestPrice > twap
            ? latestPrice - twap
            : twap - latestPrice;

        if (
            (uint256(priceDiff) * 10000) / uint256(twap) > DEVIATION_THRESHOLD
        ) {
            return (true, abi.encode(latestPrice, twap));
        }

        return (false, "");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TwapResponse is Ownable {
    constructor() Ownable(msg.sender) {}

    event PriceDeviation(uint256 currentPrice, uint256 twap, address sender);

    // @notice This function is called by the Drosera network when the TwapOracleTrap triggers a response.
    // @param currentPrice The current price from the oracle.
    // @param twap The time-weighted average price.
    function priceDeviation(uint256 currentPrice, uint256 twap) external {
        // You can add any logic here to handle the price deviation.
        // For example, you could log the event, notify a user, or execute a trade.
        emit PriceDeviation(currentPrice, twap, msg.sender);
    }
}

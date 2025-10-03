# TWAP Oracle Trap

This is a Drosera trap that monitors a Chainlink price feed and triggers a response if the price deviates from the Time-Weighted Average Price (TWAP) by a certain threshold.

## How it works

This project is designed to be a reactive, decentralized oracle monitoring system built on the Drosera network.

### The Trap: `TwapOracleTrap.sol`

The main contract, `TwapOracleTrap.sol`, is a Drosera trap. Here's the logic:

1.  **`collect()`**: This function is called by Drosera operators at regular intervals. It fetches the latest price from a hardcoded Chainlink price feed (in this case, ETH/USD).

2.  **`shouldRespond()`**: This function is also called by Drosera operators. It receives a history of the collected prices. It calculates the TWAP from this history and compares it to the latest price. If the deviation is greater than a hardcoded threshold (currently 1%), it returns `true`, signaling to the Drosera network that a response should be triggered.

### The Response: `TwapResponse.sol`

When the trap is triggered, the Drosera network calls the `priceDeviation` function on the `TwapResponse.sol` contract. This contract is a separate contract that is deployed using Foundry. The `drosera.toml` file is configured to point to this contract and function.

The `priceDeviation` function in `TwapResponse.sol` currently just emits an event with the current price and the TWAP. However, you can customize this function to perform any action you want, such as:

*   Sending a notification to a monitoring service.
*   Executing a trade on a DEX.
*   Adjusting parameters in a DeFi protocol.

## Testing

This project uses Foundry for testing. The tests are located in the `test` directory.

To run the tests, you can use the following command:

```bash
forge test
```

The tests use a mock Chainlink price feed to simulate different price scenarios and ensure the trap triggers at the correct times.

## Deployment

This project has two main components to deploy:

1.  **`TwapResponse.sol`**: This contract is deployed using Foundry. A deployment script is provided in `scripts/DeployTwapResponse.s.sol`. You can deploy it by running:

    ```bash
    forge script scripts/DeployTwapResponse.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
    ```

2.  **`TwapOracleTrap.sol`**: This contract is deployed using the Drosera CLI. Before deploying the trap, you need to update the `drosera.toml` file with the address of the deployed `TwapResponse` contract and the function signature of the response function.

    After deploying the `TwapResponse` contract, you will get an address. You need to add the following lines to your `drosera.toml` file under the `[traps.twap_oracle_trap]` section:

    ```toml
    response_contract = "<address_of_TwapResponse_contract>"
    response_function = "triggerTwap(uint256, uint256, uint256)"
    ```

    Then, you can deploy the trap using the Drosera CLI:

    ```bash
    DROSERA_PRIVATE_KEY=0x... drosera apply
    ```
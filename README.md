# ONS on Axelar sample

Basic verification of ONS domain name minting & propegating using a mocked Axelar environment.

## Contracts
`ONS.sol` : Contains the core ERC721 + domain name registry logic.
`AxelarMessenger.sol` : Implements the Axelar messaging logic. Handles propagating messages to all chains.
`AxelarGatewayGasServiceMock.sol` : Mocking out the gateway & gasService contracts. Trivially passes messages through to destination contract.

## Architecture
ONS is an omnichain name service. Users can mint a domain name (e.g. wagmi.ons) and that domain will be minted as a token and its metadata be propagated to all target chains using Axelar.

After `ONS.sol` updates its internal state upon mint, it will call into `AxelarMessenger.sol` to propagate the message. This separation allows for upgrading of the Axelar messaging functionality without needing to upgrate or migrate the ONS state.

`AxelarMessenger.sol` contains two functions: `sendMint` and `_execute`:
- `sendMint` will encode the payload and then send it to all destination blockchains defined in `dstChains`. The msg.value of `sendMint` should include all the gas necessary for the message, and will be allocated evenly for each cross-chain call. It should be noted that this is a trivial implementation of gas allocation, as it assumes all chains cost the same which is not true. Upon paying gas to the `gasReceiver`, it will then call `callContract` on the `gateway`.

- `_execute` is executed on the destination chain by the `gateway` upon receiving a message. It will decode the payload, create the Record object, and call back into the local chain's `ONS.sol` contract. It's expected the destination chain's `ONS.sol` will update its state with the Record.

`AxelarGatewayGasServiceMock.sol` just blindly passes messages along. It mocks out the gas receiver and gateway functionality of the Axelar network.

### Sequence diagram
![Axelar Sequence Diagram](https://github.com/ori-wagmi/axelar_poc_public/blob/main/Images/Axelar%20Sequence%20Diagram.png)

## Test
Mints a domain name and verifies it gets propagated to all chains.

run with `npx hardhat test`

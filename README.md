# ONS on Axelar sample

Basic verification of ONS domain name minting & propegating using a mocked Axelar environment.

## Contracts
`ONS.sol` : Contains the core ERC721 + domain name registry logic.
`AxelarMessenger.sol` : Implements the Axelar messaging logic. Handles propagating messages to all chains.
`AxelarGatewayGasServiceMock.sol` : Mocking out the gateway & gasService contracts. Trivially passes messages through to destination contract.

## Test
Mints a domain name and verifies it gets propagated to all chains.

run with `npx hardhat test`
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
// import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
// import { IAxelarGateway } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarExecutable.sol";
import {StringToAddress, AddressToString} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/StringAddressUtils.sol";

interface IMessengerGetter {
    function messenger() external returns (address);
}

// Mocking out the Axelar Gateway & GasService for testing purposes. 
contract AxelarGatewayGasServiceMock {
    using StringToAddress for string;
    using AddressToString for address;

    function callContract(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external {
        IAxelarExecutable(
            IMessengerGetter(contractAddress.toAddress()).messenger()
        ).execute("0x", destinationChain, contractAddress, payload);
    }

    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable {}

    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external returns (bool) {
        return true;
    }
}

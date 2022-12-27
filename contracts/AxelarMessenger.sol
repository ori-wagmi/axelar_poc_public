// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol";
import {StringToAddress, AddressToString} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/StringAddressUtils.sol";

struct Record {
    address owner;
    address ethAddress;
}

interface IONS {
    function _updateRecord(bytes32 _domain, Record memory _record) external;
}

contract AxlearMessenger is AxelarExecutable {
    using StringToAddress for string;
    using AddressToString for address;

    string[] dstChains;
    address[] dstAddress;

    IAxelarGasService public immutable gasReceiver;
    IONS public ons;

    constructor(
        address gateway_,
        address gasReceiver_
    ) AxelarExecutable(gateway_) {
        gasReceiver = IAxelarGasService(gasReceiver_);
    }

    function setup(
        address _ons,
        string[] memory _chains,
        address[] memory _address
    ) external {
        ons = IONS(_ons);
        dstChains = _chains;
        dstAddress = _address;
    }

    function sendMint(
        address _owner,
        bytes32 _domain,
        address _refundAddress
    ) external payable {
        bytes memory payload = abi.encode(_owner, _domain);

        for (uint i = 0; i < dstChains.length; i++) {
            string memory dstChain = dstChains[i];
            string memory dstAddr = dstAddress[i].toString();
            // todo: need to optimize gas calculation
            gasReceiver.payNativeGasForContractCall{value: (msg.value / dstChains.length)}(
                address(this),
                dstChain,
                dstAddr,
                payload,
                _refundAddress
            );
            //Call the remote contract.
            gateway.callContract(dstChain, dstAddr, payload);
        }
    }

    //This is automatically executed by Axelar Microservices since gas was payed for.
    function _execute(
        string calldata /*sourceChain*/,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        //Decode the payload.
        (address owner, bytes32 domain) = abi.decode(
            payload,
            (address, bytes32)
        );

        Record memory record;
        record.ethAddress = owner;
        record.owner = owner;
        ons._updateRecord(domain, record);
    }
}

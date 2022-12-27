// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IMessenger {
    function sendMint(
        address _owner,
        bytes32 _domain,
        address _refundAddress
    ) external payable;
}

contract Generic_ONS is ERC721 {
    struct Record {
        address owner;
        address ethAddress;
    }

    // records maps a nameHash to the Record struct, which represents a subset of the ENS metadata.
    // https://docs.ens.domains/contract-api-reference/name-processing#hashing-names
    mapping(bytes32 => Record) public records;
    mapping(bytes32 => bool) public registeredName;

    IMessenger public messenger;

    constructor(
        string memory _name,
        string memory _symbol,
        address _messenger
    ) ERC721(_name, _symbol) {
        messenger = IMessenger(_messenger);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(
        address _owner,
        bytes32 _domain,
        address _refundAddress
    ) external payable {
        require(!_exists(uint(_domain)));
        require(!registeredName[_domain]);

        registeredName[_domain] = true;
        records[_domain].owner = _owner;
        records[_domain].ethAddress = _owner;

        _safeMint(_owner, uint(_domain));

        messenger.sendMint{value: msg.value}(_owner, _domain, _refundAddress);
    }

    function _updateRecord(bytes32 _domain, Record memory _record) external {
        if (!registeredName[_domain]) {
            registeredName[_domain] = true;
        }
        records[_domain] = _record;
    }
}

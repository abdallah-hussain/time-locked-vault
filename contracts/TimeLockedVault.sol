
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./core/VaultCore.sol";
contract TimeLockedSavingsVault is VaultCore{
    address public owner; // Contract Owner (Bank Manager)

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender; // Set The Contract Owner First Time When Deploying The Contract
    }
}

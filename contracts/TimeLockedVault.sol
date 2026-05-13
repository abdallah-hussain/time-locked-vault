
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract TimeLockedSavingsVault {
    address public owner; // Contract Owner (Bank Manager)
    uint256 public constant MINIMUM_DEPOSIT = 0.01 ether; //You cannot deposit less than 0.01 ETH
    uint256 public constant LOCK_DURATION = 7 days;
    struct Account { // create struct to store each user’s money data
        uint256 balance; // how much money user deposited
        uint256 unlockTime; //when user can withdraw

    }
    mapping(address => Account) public accounts; // Connect user to thier accounts

    constructor() {
        owner = msg.sender; // Set The Contract Owner First Time When Deploying The Contract
       
    }

    event Deposited( //Create blockchain log: who deposited,how much,unlock time
        address indexed user,
        uint256 indexed amount, 
        uint256 unlockTime  
        );


    event Withdrawn( //Create blockchain log: who Withdraw,how much
        address indexed user,
        uint256 indexed amount
        );

    error NoBalance();
    error DepositTooSmall();
    error FundsStillLocked();
    error InvalidAmount();
    error InsufficientBalance(address account,uint256 balance,uint256 amount);

    modifier hasBalance() {
        if (accounts[msg.sender].balance == 0) {
            revert NoBalance();
        }
        _;
    }

    modifier enoughDeposit() {
        if (msg.value < MINIMUM_DEPOSIT) {
            revert DepositTooSmall();
        }
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }


    modifier lockedTime() {
        if (block.timestamp < accounts[msg.sender].unlockTime) {
            revert FundsStillLocked();
        }
        _;
    }

    modifier invalidAmount(uint256 amount) {
        if (amount ==0) {
            revert InvalidAmount();
        }
        _;
    }

    function _max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a:b;
    }
    function deposit(uint256 lockTime) public payable enoughDeposit {

        uint256 newUnlockTime = block.timestamp + LOCK_DURATION;

        accounts[msg.sender].balance += msg.value;  // Store money in the account
        
        accounts[msg.sender].unlockTime = _max(accounts[msg.sender].unlockTime, newUnlockTime);  // block.timestamp it's Current time on blockchain

        emit Deposited(msg.sender,msg.value,accounts[msg.sender].unlockTime);
    }

    function withdraw(uint256 amount) public hasBalance lockedTime invalidAmount(amount) { 
        /*
            1. CHECK conditions
            2. UPDATE state
            3. INTERACT externally
        */

        if(accounts[msg.sender].balance < amount) {
            revert InsufficientBalance(
                msg.sender,
                accounts[msg.sender].balance,
                amount
            );
        }

        // payable(msg.sender).transfer(amount); not modern ,limited / deprecated / unsafe patterns
        /*
        Send ETH to the user safely AND check if the transfer worked
        ("") empty data This means:no function call, just send ETH
        (bool success, ) What is this?
            .call() returns TWO values:
                1. success (true/false)
                2. return data (ignored here)
        
        */

        // UPDATE STATE FIRST   
        accounts[msg.sender].balance -= amount;
        // INTERACTION
        (bool success, ) =  payable(msg.sender).call{value: amount}("");
        require(success,"Transfer Failed");
        emit Withdrawn(msg.sender,amount);

        if (accounts[msg.sender].balance == 0){
            accounts[msg.sender].unlockTime = 0;
        }

    }

    function getMyBalance() public view returns (uint256) { // View function to show User Balance 
        return accounts[msg.sender].balance;
    }

    function getMyUnlockTime() public view returns (uint256){ //View function to show time block to withdraw
        return accounts[msg.sender].unlockTime;
    }

    function getRemainingTime() public view returns (uint256){ //View function to show remaining time to withdraw
        if(block.timestamp >= accounts[msg.sender].unlockTime){
            return 0;
        }

        return  accounts[msg.sender].unlockTime - block.timestamp;
    }

    function getContractBalance() public view returns (uint256){
        return address(this).balance; // return Current contract address balance
    }

}

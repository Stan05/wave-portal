// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Ownable.sol";

contract WavePortal is Ownable {

    mapping(address => uint256) public lastWavedAt;

    uint256 private totalWaves;
    uint256 private prizeAmount;
    /// @dev will be used to generate random number
    uint256 private seed;

    constructor() payable {
        prizeAmount = 0.0001 ether;

        seed = (block.timestamp + block.difficulty) % 100;
    }

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver; 
        string message; 
        uint256 timestamp; 
    }

    Wave[] private waves;

    function setPrizeAmount(uint256 _prizeAmount) public onlyOwner {
        prizeAmount = _prizeAmount;
    }

    function wave(string memory _message) public {
        
        require(
            lastWavedAt[msg.sender] + 1 minutes < block.timestamp,
            "Wait 15m"
        );
        
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s waved w/ message %s", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

                /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}
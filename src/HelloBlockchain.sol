// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloBlockchain {
    string public message;

    // Constructor to set the initial message
    constructor(string memory initialMessage) {
        message = initialMessage;
    }

    // Function to update the message
    function updateMessage(string memory newMessage) public {
        message = newMessage;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26;
import "@openzeppelin/contracts/access/Ownable.sol";

contract GasManager is Ownable {
    uint256 transactionFee;
    constructor(uint256 _transactionFee) Ownable(msg.sender) {
        transactionFee = _transactionFee;
    }

    function setTransactionFee(uint256 _transactionFee) public {
        require(
            _transactionFee > 0,
            "Wrong value of transaction fees , should e.g 3 - that will be in percentage"
        );
    }
}

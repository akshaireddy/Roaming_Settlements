// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoamingContract {
    address public owner;
    uint256 public roamingFee;

    enum Network { Home, Partner1, Partner2, Partner3 } // Define different networks

    struct RoamingRecord {
        Network fromNetwork;
        Network toNetwork;
        uint256 startTime;
        uint256 endTime;
        bool settled;
    }

    mapping(address => RoamingRecord[]) public roamingRecords;

    event RoamingStarted(address indexed user, Network fromNetwork, Network toNetwork, uint256 startTime);
    event RoamingEnded(address indexed user, Network fromNetwork, Network toNetwork, uint256 endTime);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint256 _roamingFee) {
        owner = msg.sender;
        roamingFee = _roamingFee;
    }

    function startRoaming(Network _toNetwork) external payable {
        require(msg.value >= roamingFee, "Insufficient funds to start roaming");

        Network fromNetwork = Network.Home; // Assume user is roaming from the home network
        RoamingRecord memory record = RoamingRecord(fromNetwork, _toNetwork, block.timestamp, 0, false);
        roamingRecords[msg.sender].push(record);

        emit RoamingStarted(msg.sender, fromNetwork, _toNetwork, block.timestamp);
    }

    function endRoaming(uint256 recordIndex) external {
        require(recordIndex < roamingRecords[msg.sender].length, "Invalid record index");

        RoamingRecord storage record = roamingRecords[msg.sender][recordIndex];
        require(!record.settled, "Roaming already settled");
        record.endTime = block.timestamp;
        record.settled = true;

        emit RoamingEnded(msg.sender, record.fromNetwork, record.toNetwork, block.timestamp);
    }

    function settleRoaming(address user, uint256 recordIndex) external onlyOwner {
        require(recordIndex < roamingRecords[user].length, "Invalid record index");
        RoamingRecord storage record = roamingRecords[user][recordIndex];
        require(!record.settled, "Roaming already settled");

        uint256 duration = record.endTime - record.startTime;
        uint256 amountToPay = (duration * roamingFee) / 1 days; // Simplified calculation

        // Transfer the calculated amount to the user
        payable(user).transfer(amountToPay);

        record.settled = true;
    }
}

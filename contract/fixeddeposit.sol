// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FixedDeposit {
    address public owner;

    struct Deposit {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        bool withdrawn;
    }

    mapping(address => Deposit) public deposits;

    event Deposited(address indexed user, uint256 amount, uint256 duration);
    event Withdrawn(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Deposit ETH with a lock-in period (in seconds)
    function deposit(uint256 _durationInSeconds) external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(deposits[msg.sender].amount == 0, "Existing deposit must be withdrawn first");

        deposits[msg.sender] = Deposit({
            amount: msg.value,
            startTime: block.timestamp,
            duration: _durationInSeconds,
            withdrawn: false
        });

        emit Deposited(msg.sender, msg.value, _durationInSeconds);
    }

    // Withdraw funds after maturity
    function withdraw() external {
        Deposit storage userDeposit = deposits[msg.sender];

        require(userDeposit.amount > 0, "No deposit found");
        require(!userDeposit.withdrawn, "Already withdrawn");
        require(block.timestamp >= userDeposit.startTime + userDeposit.duration, "Deposit still locked");

        uint256 amount = userDeposit.amount;
        userDeposit.withdrawn = true;
        userDeposit.amount = 0;

        payable(msg.sender).transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }

    // View user deposit
    function getDeposit(address _user) external view returns (uint256 amount, uint256 startTime, uint256 duration, bool withdrawn) {
        Deposit memory dep = deposits[_user];
        return (dep.amount, dep.startTime, dep.duration, dep.withdrawn);
    }

    // View contract balance
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}


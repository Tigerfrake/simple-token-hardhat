//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;


// This is the main building block for smart contracts.
contract Token {
    // Some string type variables to identify the token.
    string public name = "My Hardhat Token";
    string public symbol = "MHT";

    // The fixed amount of tokens, stored in an unsigned integer type variable.
    uint256 public fundingAmount = 1000000;

    uint256 public totalDeposit;

    // An address type variable is used to store ethereum accounts.
    address public owner;

    // A mapping is a key/value map. Here we store each account's balance.
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public deposits;

    // The Transfer event helps off-chain applications understand
    // what happens within your contract.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    /**
     * Contract initialization.
     */
    constructor() {
        // The totalSupply is assigned to the transaction sender, which is the
        // account that is deploying the contract.
        balances[msg.sender] = fundingAmount;
        owner = msg.sender;
    }

    /**
     * Allows a user to deposit tokens into the contract
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        deposits[msg.sender] += amount;
        totalDeposit += amount;
        emit Transfer(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount);
    }

    /**
     * Allows a user to withdraw tokens from the contract
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Insufficient deposit balance");
        
        deposits[msg.sender] -= amount;
        balances[msg.sender] += amount;
        totalDeposit -= amount;
        emit Transfer(address(this), msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    /**
     * Returns the amount of tokens deposited by a specific address
     */
    function getDepositBalance(address account) external view returns (uint256) {
        return deposits[account];
    }

    /**
     * Approves another address to spend tokens on behalf of the owner
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * Transfers tokens from one address to another using an allowance
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        require(balances[from] >= amount, "Insufficient balance");

        allowance[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * A function to transfer tokens.
     *
     * The `external` modifier makes a function *only* callable from *outside*
     * the contract.
     */
    function transfer(address to, uint256 amount) external {
        // Check if the transaction sender has enough tokens.
        // If `require`'s first argument evaluates to `false`, the
        // transaction will revert.
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // Transfer the amount.
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Notify off-chain applications of the transfer.
        emit Transfer(msg.sender, to, amount);
    }

    /**
     * Read only function to retrieve the token balance of a given account.
     *
     * The `view` modifier indicates that it doesn't modify the contract's
     * state, which allows us to call it without executing a transaction.
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function getAllowance(address from, address spender) external view returns (uint256) {
        return allowance[from][spender];
    }
}
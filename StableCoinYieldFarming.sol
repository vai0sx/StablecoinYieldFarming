// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract StablecoinYieldFarming {

    // The address of the AAVE protocol.
    address public aave;

    // The mapping from lender addresses to the amount of stablecoins they have lent.
    mapping(address => uint256) public lenderBalances;

    // The mapping from borrower addresses to the amount of stablecoins they have borrowed.
    mapping(address => uint256) public borrowerBalances;

    // The interest rate for lending stablecoins.
    uint256 public interestRate;

    // The constructor sets the address of the AAVE protocol and the interest rate.
    constructor(address _aave, uint256 _interestRate) {
        aave = _aave;
        interestRate = _interestRate;
    }

    // The `lend` function allows a user to lend stablecoins to the protocol.
    function lend(uint256 amount) public {
        // Check that the user has enough stablecoins to lend.
        require(amount <= address(this).balance);

        // Update the lender's balance.
        lenderBalances[msg.sender] += amount;

        // Update the protocol's balance.
        uint256 contractBalance = address(this).balance;
        contractBalance -= amount;
        // Update the contract balance.
        payable(address(this)).transfer(contractBalance);

        // Pay the lender interest.
        interest(amount);
    }

    // The `borrow` function allows a user to borrow stablecoins from the protocol.
    function borrow(uint256 amount) public {
        // Check that the user has enough collateral to borrow.
        require(amount <= IERC20(aave).balanceOf(msg.sender));

        // Update the borrower's balance.
        borrowerBalances[msg.sender] += amount;

        // Transfer stablecoins from borrower to contract.
        IERC20(aave).transferFrom(msg.sender, address(this), amount);

        // Pay the borrower interest.
        interest(amount);
    }

    // The `interest` function pays the lender and borrower interest on their balances.
    function interest(uint256 _amount) internal {
        // Calculate the interest amount.
        uint256 interestAmount = _amount * interestRate / 100;

        // Pay the lender interest.
        if (lenderBalances[msg.sender] > 0) {
            lenderBalances[msg.sender] -= interestAmount;
        }

        // Pay the borrower interest.
        if (borrowerBalances[msg.sender] > 0) {
            borrowerBalances[msg.sender] += interestAmount;
        }
    }
}

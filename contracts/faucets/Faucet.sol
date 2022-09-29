// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Faucet {
	address public admin;
	uint public count = 0;

	struct Account {
		uint192 amount;
		uint64 lasttime;
	}
	
	mapping(address=>Account) public holders;

	constructor(address _admin) {
		admin = _admin;
	}

	modifier onlyAdmin() {
		require(msg.sender == admin);
		_;
	}
	
	receive() external payable {}
	
	function withdraw() external payable onlyAdmin {
		(bool result, ) = payable(msg.sender).call{value: address(this).balance}("");
		require(result);
	}

	function canReceive(address account) public view returns(bool) {
		return account.code.length == 0 && holders[account].amount<1 ether && block.timestamp - holders[account].lasttime > 1 days;
	}
    function transfer(address[] memory accounts, uint amount) external payable onlyAdmin {
		for(uint i=0; i<accounts.length; i++) {
			if (canReceive(accounts[i])) {
				Account storage holder = holders[accounts[i]];
				(bool result, ) = payable(accounts[i]).call{value: amount}("");
				if (result) {
					count++;
					holder.amount += uint192(amount);
					holder.lasttime += uint64(block.timestamp);
				}
			}
		}
	}
}
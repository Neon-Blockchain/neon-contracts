// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WETH9 {
    string public name     = "Wrapped Neon";
    string public symbol   = "WNEON";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint amount);
    event  Transfer(address indexed src, address indexed dst, uint amount);
    event  Deposit(address indexed dst, uint amount);
    event  Withdrawal(address indexed src, uint amount);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function _transfer(address src, address dst, uint amount) internal returns (bool) {
        require(balanceOf[src] >= amount);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint).max) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }

        balanceOf[src] -= amount;
        balanceOf[dst] += amount;

        emit Transfer(src, dst, amount);

        return true;
    }

    receive() external payable  {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
        emit Withdrawal(msg.sender, amount);
    }

    function totalSupply() external view returns (uint) {
        return address(this).balance;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    

    function transfer(address dst, uint amount) external returns (bool) {
        return _transfer(msg.sender, dst, amount);
    }

    function transferFrom(address src, address dst, uint amount) external returns (bool) {
        return _transfer(src, dst, amount);
    }
}
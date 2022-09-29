// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);

	mapping(address => bool) public isMinter;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    
    address public owner;
    uint256 public override totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint _initialMint) {
        owner = msg.sender;
        addMinter(owner);
        name = _name;
        symbol = _symbol;
        decimals = 18;
        if (_initialMint!=0) _mint(msg.sender, _initialMint * 10 ** uint(decimals));
    }

	modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyMinter() {
        require(isMinter[msg.sender]);
        _;
    }

    function addMinter(address minter) public onlyOwner {
        require(minter!=msg.sender && !isMinter[msg.sender]);
        isMinter[msg.sender] = true;
        emit MinterAdded(minter);
    }
    
    function removeMinter(address minter) public onlyOwner {
        require(minter!=msg.sender && isMinter[msg.sender]);
        isMinter[msg.sender] = false;
        emit MinterRemoved(minter);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        require(allowance[sender][msg.sender] >= amount, 'ERC20: transfer amount exceeds allowance');
        _approve(sender, msg.sender, allowance[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        uint c = allowance[msg.sender][spender] + addedValue;
        require(c >= addedValue, "SafeMath: addition overflow");
        _approve(msg.sender, spender, c);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(allowance[msg.sender][spender] >= subtractedValue, 'ERC20: decreased allowance below zero');
        _approve(msg.sender, spender, allowance[msg.sender][spender] - subtractedValue);
        return true;
    }

    function mint(uint256 amount) public onlyMinter returns (bool) {
        _mint(msg.sender, amount);
        return true;
    }

    function mintTo(address account, uint256 amount) external onlyMinter {
        _mint(account, amount);
    }
    
    function burnFrom(address account, uint256 amount) external onlyMinter {
        _burn(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'ERC20: transfer from the zero address');
        require(recipient != address(0), 'ERC20: transfer to the zero address');
        require(balanceOf[sender] >= amount, 'ERC20: transfer amount exceeds balance');
        balanceOf[sender] -= amount;
        uint c = balanceOf[recipient] + amount;
        require(c >= amount, "SafeMath: addition overflow");
        balanceOf[recipient] = c;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'ERC20: mint to the zero address');
        uint c = totalSupply + amount;
        require(c >= amount, "SafeMath: addition overflow");
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'ERC20: burn from the zero address');
        require(balanceOf[account] >= amount, 'ERC20: burn amount exceeds balance');
        balanceOf[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address account, address spender, uint256 amount) internal {
        require(account != address(0), 'ERC20: approve from the zero address');
        require(spender != address(0), 'ERC20: approve to the zero address');
        allowance[account][spender] = amount;
        emit Approval(account, spender, amount);
    }
}
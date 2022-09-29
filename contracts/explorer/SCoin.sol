// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Initializable {
	bool private initialized;
	bool private initializing;
	modifier initializer() {
		require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

		bool isTopLevelCall = !initializing;
		if (isTopLevelCall) {
			initializing = true;
			initialized = true;
		}
		_;
		if (isTopLevelCall) {
			initializing = false;
		}
	}
	function isConstructor() private view returns (bool) {
		address self = address(this);
		uint cs;
		assembly { cs := extcodesize(self) }
		return cs == 0;
	}
	uint[50] private ______gap;
}
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        return c;
    }
    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract ERC20Detailed is Initializable {
    string public name;
    string public symbol;
    uint8 public decimals;
    function initialize(string memory _name, string memory _symbol, uint8 _decimals) internal initializer {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    uint[50] private ______gap;
}

contract ERC20 is Initializable {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);
	
    using SafeMath for uint;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    uint private _totalSupply;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _burnFrom(address account, uint amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint[50] private ______gap;
}

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }
    function add(Role storage role, address account) internal {
        require(account != address(0));
        role.bearer[account] = true;
    }
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        role.bearer[account] = false;
    }
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    function renounceMinter() public {
        minters.remove(msg.sender);
    }

    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }

    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    uint[50] private ______gap;
}

contract ERC20Mintable is ERC20, MinterRole {
    event MintingFinished();

    bool private _mintingFinished = false;

    modifier onlyBeforeMintingFinished() {
        require(!_mintingFinished);
        _;
    }

    function mintingFinished() public view returns (bool) {
        return _mintingFinished;
    }

    function mint(address to, uint amount) public onlyMinter onlyBeforeMintingFinished returns (bool) {
        _mint(to, amount);
        return true;
    }

    function finishMinting() public onlyMinter onlyBeforeMintingFinished returns (bool) {
        _mintingFinished = true;
        emit MintingFinished();
        return true;
    }
}

// contract ERC20Burnable is ERC20 {
//     function burn(uint value) public {
//         _burn(msg.sender, value);
//     }
//     function burnFrom(address from, uint value) public {
//         _burnFrom(from, value);
//     }
//     function _burn(address who, uint value) internal {
//         super._burn(who, value);
//     }
// }

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract WhitelistedRecipientRole {
    using Roles for Roles.Role;

    event WhitelistedRecipientAdded(address indexed account);
    event WhitelistedRecipientRemoved(address indexed account);

    Roles.Role private whitelistedRecipients;

    modifier onlyWhitelistedRecipient() {
        require(isWhitelistedRecipient(msg.sender));
        _;
    }

    function isWhitelistedRecipient(address account) public view returns (bool) {
        return whitelistedRecipients.has(account);
    }

    function renounceWhitelistedRecipient() public {
        whitelistedRecipients.remove(msg.sender);
    }

    function _removeWhitelistedRecipient(address account) internal {
        whitelistedRecipients.remove(account);
        emit WhitelistedRecipientRemoved(account);
    }

    function _addWhitelistedRecipient(address account) internal {
        whitelistedRecipients.add(account);
        emit WhitelistedRecipientAdded(account);
    }

    uint[50] private ______gap;
}

contract WhitelistedSenderRole {
    using Roles for Roles.Role;

    event WhitelistedSenderAdded(address indexed account);
    event WhitelistedSenderRemoved(address indexed account);

    Roles.Role private whitelistedSenders;

    modifier onlyWhitelistedSender() {
        require(isWhitelistedSender(msg.sender));
        _;
    }

    function isWhitelistedSender(address account) public view returns (bool) {
        return whitelistedSenders.has(account);
    }

    function renounceWhitelistedSender() public {
        whitelistedSenders.remove(msg.sender);
    }

    function _removeWhitelistedSender(address account) internal {
        whitelistedSenders.remove(account);
        emit WhitelistedSenderRemoved(account);
    }

    function _addWhitelistedSender(address account) internal {
        whitelistedSenders.add(account);
        emit WhitelistedSenderAdded(account);
    }

    uint[50] private ______gap;
}

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract SCoin is ERC20, ERC20Detailed, ERC20Mintable, Ownable, WhitelistedRecipientRole, WhitelistedSenderRole { /* ERC20Burnable,  */

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * initialization.
     */
    constructor() {
        // initialize the token
        ERC20Detailed.initialize("Staked NEON", "NEON", 18);

        // initialize the Ownable
        // _transferOwnership(owner);
    }

    function addMinter(address account) external onlyOwner {
        _addMinter(account);
    }

    function removeMinter(address account) external onlyOwner {
        _removeMinter(account);
    }

    function addWhitelistedSender(address account) external onlyOwner {
        _addWhitelistedSender(account);
    }

    function removeWhitelistedSender(address account) external onlyOwner {
        _removeWhitelistedSender(account);
    }

    function addWhitelistedRecipient(address account) external onlyOwner {
        _addWhitelistedRecipient(account);
    }

    function removeWhitelistedRecipient(address account) external onlyOwner {
        _removeWhitelistedRecipient(account);
    }

    function isWhitelisted(address sender, address recipient) public view returns (bool) {
        return isWhitelistedSender(sender) || isWhitelistedRecipient(recipient);
    }

    function transfer(address to, uint value) public override returns (bool) {
        require(isWhitelisted(msg.sender, to), "not whitelisted");
        return ERC20.transfer(to, value);
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        require(isWhitelisted(msg.sender, recipient), "not whitelisted");
        return ERC20.transferFrom(sender, recipient, amount);
    }

    function approve(address spender, uint value) public override returns (bool) {
        require(isWhitelisted(msg.sender, spender), "not whitelisted");
        return ERC20.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public override returns (bool) {
        require(isWhitelisted(msg.sender, spender), "not whitelisted");
        return ERC20.increaseAllowance(spender, addedValue);
    }
}
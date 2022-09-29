// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SFC {
    function getLockedStake(address delegator, uint256 toValidatorID) external view returns (uint256);
}
interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function burnFrom(address from, uint256 value) external;
    function mint(address to, uint256 amount) external returns (bool);
}

contract StakeTokenizer {
    address private _owner;
    SFC internal sfc = SFC(0xeAb1000000000000000000000000000000000000);
    mapping(address => mapping(uint256 => uint256)) public outstandingSCoin;
    address public sCoinTokenAddress;

    constructor (address _sCoinTokenAddress )  {
        sCoinTokenAddress = _sCoinTokenAddress;
    }

    function mintSCoin(uint256 toValidatorID) external {
        address delegator = msg.sender;
        uint256 lockedStake = sfc.getLockedStake(delegator, toValidatorID);
        require(lockedStake > 0, "delegation isn't locked up");
        require(lockedStake > outstandingSCoin[delegator][toValidatorID], "already minted");

        uint256 diff = lockedStake - outstandingSCoin[delegator][toValidatorID];
        outstandingSCoin[delegator][toValidatorID] = lockedStake;
        require(IERC20(sCoinTokenAddress).mint(delegator, diff), "failed to mint");
    }

    function redeemSCoin(uint256 validatorID, uint256 amount) external {
        require(outstandingSCoin[msg.sender][validatorID] >= amount, "low outstanding balance");
        require(IERC20(sCoinTokenAddress).allowance(msg.sender, address(this)) >= amount, "insufficient allowance");
        outstandingSCoin[msg.sender][validatorID] -= amount;
        IERC20(sCoinTokenAddress).burnFrom(msg.sender, amount);
    }

    function allowedToWithdrawStake(address sender, uint256 validatorID) public view returns(bool) {
        return outstandingSCoin[sender][validatorID] == 0;
    }
}
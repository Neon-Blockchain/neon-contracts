// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SFC {
    function getValidatorID(address addr) external view returns (uint256);
}

contract StakerInfo {
	event InfoUpdated(uint256 stakerID);

	mapping (uint => string) public stakerInfos;
	string private _uri = "https://ipfs.io/ipfs/QmSQqoqC7QMWqtkPhTifgSHuinXEC8JQStVW6qHRN4hNCK";
	uint constant private _initialValidators = 8;
	address internal stakerContractAddress = 0xeAb1000000000000000000000000000000000000;

	function setBaseUri(string memory _configUrl) external {
		_uri = _configUrl;
	}

	function updateInfo(address _sender, string memory _configUrl) external {
		require(msg.sender!=address(0));
		SFC stakersInterface = SFC(stakerContractAddress);
		uint256 stakerID = stakersInterface.getValidatorID(_sender);
		require(stakerID != 0, "Address does not belong to a staker!");
		stakerInfos[stakerID] = _configUrl;
		emit InfoUpdated(stakerID);
	}

	function getInfo(uint256 _stakerID) external view returns (string memory) {
		if (_stakerID <= _initialValidators) return _uri;
		return stakerInfos[_stakerID];
	}
}
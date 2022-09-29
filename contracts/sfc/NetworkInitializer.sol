// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SFC {
	function initialize(uint256 sealedEpoch, uint256 _totalSupply, address nodeDriver, address owner) external;
}
interface NodeDriver {
	function initialize(address _backend, address _evmWriterAddress) external;
}
interface NodeDriverAuth {
	function initialize(address _sfc, address _driver, address _owner) external;
}

contract NetworkInitializer {
    function initializeAll(uint256 sealedEpoch, uint256 totalSupply, address _sfc, address _auth, address _driver, address _evmWriter, address _owner) external {
        NodeDriver(_driver).initialize(_auth, _evmWriter);
        NodeDriverAuth(_auth).initialize(_sfc, _driver, _owner);
        SFC(_sfc).initialize(sealedEpoch, totalSupply, _auth, _owner);
        selfdestruct(payable(address(0)));
    }
}

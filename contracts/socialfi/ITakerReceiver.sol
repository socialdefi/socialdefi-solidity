// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

interface ITakerReceiver {
	/**
	 * @dev Receive taker from `from_` .
	 */
	function takerFrom(address from_, uint256 takerId_) external;
}

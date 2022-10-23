// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

import './IMaker.sol';

interface ISocialWallet is IERC165 {
	/**
	 * @dev Mint new maker order.
	 */
	function mintMaker(IMaker.Metadata memory maker_, address dex_)
		external
		payable
		returns (uint256 makerId_);

	/**
	 * @dev Close maker.
	 */
	function closeMaker(uint256 makerId_) external;

	/**
	 * @dev mint new taker order.
	 */
	function mintTaker(
		address maker_,
		uint256 makerId_,
		uint256 requestSkuQuantityOrId_,
		uint256 requestPriceQuantityOrId_
	) external payable returns (uint256 takerId_);

	/**
	 * @dev Close taker.
	 */
	function closeTaker(uint256 takerId_) external;
}

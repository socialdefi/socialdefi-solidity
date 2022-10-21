// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './IMaker.sol';

interface ITaker {
	// Emit when created a new taker order.
	event TakerMint(
		address indexed from_,
		uint256 indexed tokenId_,
		uint256 requestSkuQuantityOrId_,
		uint256 requestPriceQuantityOrId_
	);
	// Emit when closed a taker order.
	event TakerBurn(
		address indexed from_,
		uint256 indexed tokenId_,
		uint256 responseSkuQuantityOrId_,
		uint256 responsePriceQuantityOrId_
	);

	/**
	 * @dev Returns total supply of taker order opening.
	 */
	function totalSupplyOfTaker() external view returns (uint256 totalSupply_);

	/**
	 * @dev Returns taker id.
	 */
	function takerByIndex(uint256 index_) external view returns (uint256 takerId_);

	/**
	 * @dev Return taker metadata.
	 *
	 * @return maker_ taker order target contract address.
	 * @return makerId_ taker order target maker id.
	 * @return requestSkuQuantityOrId_ Number/Id of sku desired to be traded
	 * @return requestPriceQuantityOrId_  Price(quantity of erc20 or id of erc721) wish to pay.
	 */
	function takerMetadata(uint256 takerId_)
		external
		view
		returns (
			address maker_,
			uint256 makerId_,
			uint256 requestSkuQuantityOrId_,
			uint256 requestPriceQuantityOrId_
		);

	/**
	 * @dev Maker contract invoke this method to complete a dex transaction.
	 *      Implementation must check if msg.sender is maker contract address.
	 */
	function takerCallback(
		uint256 takerId_,
		uint256 responseSkuQuantityOrId_,
		uint256 responsePriceQuantityOrId_
	) external;

	/**
	 * @dev mint new taker order.
	 */
	function mintTaker(
		address depsoitFrom_,
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

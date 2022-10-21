// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

/**
 * @dev Maker order support interface
 *
 */
interface IMaker {
	struct Metadata {
		address sku;
		uint256 skuQuantityOrId;
		address paymentCurrency;
		uint256 priceQuantityOrId;
		uint128 skuType;
		uint128 paymentCurrencyType;
	}

	// Emit when created a new maker order.
	event MakerMint(address indexed from_, uint256 indexed tokenId_, address indexed dex_);
	// Emit when closed a maker order.
	event MakerBurn(address indexed from_, uint256 indexed tokenId_);

	// Emit when maker order status changed.
	event MakerUpdate(
		address indexed from_,
		uint256 indexed tokenId_,
		uint256 settleSkuQuantityOrId_,
		uint256 settlePaymentOrId_
	);

	/**
	 * @dev Returns total supply of maker order opening.
	 */
	function totalSupplyOfMaker() external view returns (uint256 totalSupply_);

	/**
	 * @dev Returns maker id.
	 */
	function makerByIndex(uint256 index_) external view returns (uint256 makerId_);

	/**
	 * @dev Return maker metadata.
	 */
	function makerMetadata(uint256 makerId_)
		external
		view
		returns (
			Metadata memory maker_,
			uint256 sentSkuQuantityOrId_,
			uint256 receivedPaymentQuantityOrId_,
			address dex_
		);

	/**
	 * @dev Approve dex to handle this maker order.
	 *
	 * @param makerId_ approve target maker id.
	 */
	function approveDex(uint256 makerId_, address to_) external payable;

	/**
	 * @dev Mint new maker order.
	 */
	function mintMaker(Metadata memory maker_, address dex_)
		external
		payable
		returns (uint256 makerId_);

	/**
	 * @dev Close maker.
	 */
	function closeMaker(uint256 makerId_) external;
}

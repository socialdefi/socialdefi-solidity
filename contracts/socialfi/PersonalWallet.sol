// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './Maker.sol';
import './Taker.sol';
import './TakerReceiver.sol';

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract PersonalWallet is Maker, Taker, TakerReceiver, IERC165, Ownable {
	///////////////////////////////////////////////////////////////////////////////////
	// internal methods
	//
	///////////////////////////////////////////////////////////////////////////////////

	function _nextId() internal override(Maker, Taker) returns (uint256) {}

	function _makerRestraint(IMaker.Metadata memory maker_) internal pure override(Maker, Taker) {
		require(maker_.sku != address(0), 'MAKER: SKU address is zero');
		require(maker_.skuQuantityOrId > 0, 'MAKER: skuQuantityOrId > 0');
		require(maker_.paymentCurrency != address(0), 'MAKER: payment currency address is zero');
		require(maker_.priceQuantityOrId > 0, 'MAKER: priceQuantityOrId > 0');
	}

	function _deposit(
		address from_,
		address asset_,
		uint256 valueOrId_,
		bool erc20_,
		bool fromETH_
	) internal override(Maker, Taker) returns (uint256 depositETH_) {}

	function _withdraw(
		address to_,
		address asset_,
		uint256 valueOrId_,
		bool erc20_,
		bool toETH_
	) internal override(Maker, Taker) {}

	function _trySwap(
		IMaker.Metadata memory metadata,
		uint256 sentSkuQuantityOrId_,
		uint256 receivedPaymentQuantityOrId_,
		uint256 requestSkuQuantityOrId_,
		uint256 requestPriceQuantityOrId_
	)
		internal
		view
		override(Taker, TakerReceiver)
		returns (uint256 suggestSkuQuantityOrId_, uint256 suggestPriceQuantityOrId_)
	{}

	function _makerMetadata(address maker_, uint256 makerId_)
		internal
		view
		override
		returns (
			IMaker.Metadata memory makerMetadata_,
			uint256 sentSkuQuantityOrId_,
			uint256 receivedPaymentQuantityOrId_,
			address dex_
		)
	{}

	function _beginInblockSwap(
		IMaker.Metadata memory metadata,
		address to_,
		uint256 approveSkuQuantityOrId_,
		uint256 expectPriceQuantityOrId_
	) internal override returns (uint256 skuQuantityOrId_, uint256 priceQuantityOrId_) {}

	function _endInblockSwap(
		IMaker.Metadata memory metadata,
		address to_,
		uint256 approveSkuQuantityOrId_,
		uint256 expectPriceQuantityOrId_
	) internal override returns (uint256 skuQuantityOrId_, uint256 priceQuantityOrId_) {}

	function _updateMaker(
		uint256 makerId_,
		uint256 sentSkuQuantityOrId_,
		uint256 receivedPaymentQuantityOrId_
	) internal override {}

	///////////////////////////////////////////////////////////////////////////////////
	// external / public methods
	//
	///////////////////////////////////////////////////////////////////////////////////

	function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
		return
			type(IMaker).interfaceId == interfaceId ||
			type(ITaker).interfaceId == interfaceId ||
			type(ITakerReceiver).interfaceId == interfaceId;
	}

	///////////////////////////////////////////////////////////////////////////////////
	// only owner call methods
	//
	///////////////////////////////////////////////////////////////////////////////////

	function mintTaker(
		address depsoitFrom_,
		address maker_,
		uint256 makerId_,
		uint256 requestSkuQuantityOrId_,
		uint256 requestPriceQuantityOrId_
	) external payable override onlyOwner returns (uint256 takerId_) {}

	function closeTaker(uint256 takerId_) external override onlyOwner {}

	/**
	 * @dev Mint new maker order.
	 */
	function mintMaker(IMaker.Metadata memory maker_, address dex_)
		external
		payable
		override
		onlyOwner
		returns (uint256 makerId_)
	{}

	/**
	 * @dev Close maker.
	 */
	function closeMaker(uint256 makerId_) external override onlyOwner {}
}

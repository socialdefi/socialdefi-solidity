// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './ITaker.sol';
import './IMaker.sol';
import './ITakerReceiver.sol';

import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

abstract contract TakerReceiver is ITakerReceiver {
	function _makerMetadata(address maker_, uint256 makerId_)
		internal
		view
		virtual
		returns (
			IMaker.Metadata memory makerMetadata_,
			uint256 sentSkuQuantityOrId_,
			uint256 receivedPaymentQuantityOrId_,
			address dex_
		);

	function _trySwap(
		IMaker.Metadata memory metadata,
		uint256 sentSkuQuantityOrId_,
		uint256 receivedPaymentQuantityOrId_,
		uint256 requestSkuQuantityOrId_,
		uint256 requestPriceQuantityOrId_
	)
		internal
		view
		virtual
		returns (uint256 suggestSkuQuantityOrId_, uint256 suggestPriceQuantityOrId_);

	function _beginInblockSwap(
		IMaker.Metadata memory metadata,
		address to_,
		uint256 approveSkuQuantityOrId_,
		uint256 expectPriceQuantityOrId_
	) internal virtual returns (uint256 skuQuantityOrId_, uint256 priceQuantityOrId_);

	function _endInblockSwap(
		IMaker.Metadata memory metadata,
		address to_,
		uint256 approveSkuQuantityOrId_,
		uint256 expectPriceQuantityOrId_
	) internal virtual returns (uint256 skuQuantityOrId_, uint256 priceQuantityOrId_);

	function _updateMaker(
		uint256 makerId_,
		uint256 sentSkuQuantityOrId_,
		uint256 receivedPaymentQuantityOrId_
	) internal virtual;

	function _inblockSwap() internal view virtual returns (bool) {
		return true;
	}

	function _swap(
		address to_,
		uint256 takerId_,
		uint256 makerId_,
		IMaker.Metadata memory makerMetadata_,
		uint256 sentSkuQuantityOrId_,
		uint256 receivedPaymentQuantityOrId_,
		uint256 requestSkuQuantityOrId_,
		uint256 requestPriceQuantityOrId_
	) internal virtual {
		(uint256 suggestSkuQuantityOrId_, uint256 suggestPriceQuantityOrId_) = _trySwap(
			makerMetadata_,
			sentSkuQuantityOrId_,
			receivedPaymentQuantityOrId_,
			requestSkuQuantityOrId_,
			requestPriceQuantityOrId_
		);

		(uint256 beginSkuQuantityOrId_, uint256 beginPriceQuantityOrId_) = _beginInblockSwap(
			makerMetadata_,
			to_,
			suggestSkuQuantityOrId_,
			suggestPriceQuantityOrId_
		);

		ITaker(to_).takerCallback(takerId_, suggestSkuQuantityOrId_, suggestPriceQuantityOrId_);

		(uint256 endSkuQuantityOrId_, uint256 endPriceQuantityOrId_) = _endInblockSwap(
			makerMetadata_,
			to_,
			suggestSkuQuantityOrId_,
			suggestPriceQuantityOrId_
		);

		uint256 swapSkuQuantityOrId_ = beginSkuQuantityOrId_ - endSkuQuantityOrId_;
		uint256 swapPaymentQuantityOrId_ = endPriceQuantityOrId_ - beginPriceQuantityOrId_;

		_updateMaker(makerId_, swapSkuQuantityOrId_, swapPaymentQuantityOrId_);
	}

	/**
	 * @dev Receive taker from `from_` .
	 */
	function takerFrom(address from_, uint256 takerId_) external override {
		(
			address maker_,
			uint256 makerId_,
			uint256 requestSkuQuantityOrId_,
			uint256 requestPriceQuantityOrId_
		) = ITaker(from_).takerMetadata(takerId_);

		(
			IMaker.Metadata memory makerMetadata_,
			uint256 sentSkuQuantityOrId_,
			uint256 receivedPaymentQuantityOrId_,
			address dex_
		) = _makerMetadata(maker_, makerId_);

		if (dex_ != address(0)) {
			require(dex_ == msg.sender, 'TAKER_RECV: only dex_ can call this method');
		} else {
			require(from_ == msg.sender, 'TAKER_RECV: only taker contract can call this method');
		}

		if (_inblockSwap()) {
			_swap(
				from_,
				takerId_,
				makerId_,
				makerMetadata_,
				sentSkuQuantityOrId_,
				receivedPaymentQuantityOrId_,
				requestSkuQuantityOrId_,
				requestPriceQuantityOrId_
			);
		}
	}
}

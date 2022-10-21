// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './IDEX.sol';
import './ITaker.sol';
import './IMaker.sol';
import './ITakerReceiver.sol';

import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

abstract contract Taker is ITaker {
	struct TakerContext {
		address maker;
		uint256 makerId;
		uint256 requestSkuQuantityOrId;
		uint256 requestPriceQuantityOrId;
		IMaker.Metadata metadata;
	}
	// using Counters
	using EnumerableSet for EnumerableSet.Bytes32Set;

	/// Maker id set
	EnumerableSet.Bytes32Set private _takerIds;

	/// Mapping maker id to Maker struct.
	mapping(uint256 => TakerContext) private _takers;

	/// mapping maker id to sent payment quantity or id
	mapping(uint256 => uint256) private _sentPaymentQuantityOrIds;

	/// mapping maker id to received sku quantity or id
	mapping(uint256 => uint256) private _receivedSkuQuantityOrIds;

	/**
	 * @dev Returns total supply of taker order opening.
	 */
	function totalSupplyOfTaker() external view returns (uint256 totalSupply_) {
		return _takerIds.length();
	}

	/**
	 * @dev Returns taker id.
	 */
	function takerByIndex(uint256 index_) external view returns (uint256 takerId_) {
		return uint256(_takerIds.at(index_));
	}

	function _requireTakerId(uint256 takerId_) private view {
		require(_takerIds.contains(bytes32(takerId_)), 'TAKER: taker id does not exist');
	}

	function _nextId() internal virtual returns (uint256);

	function _makerRestraint(IMaker.Metadata memory maker_) internal virtual;

	/**
	 * @dev deposit asset from `from_` address.
	 *
	 * @param fromETH_ if asset_ is WETH, deposit WETH from native token.
	 */
	function _deposit(
		address from_,
		address asset_,
		uint256 valueOrId_,
		bool erc20_,
		bool fromETH_
	) internal virtual returns (uint256 depositETH_);

	/**
	 * @dev Withdraw asset to `to_` address.
	 *
	 * @param toETH_ If asset_ is WETH, convert WETH to native token.
	 */
	function _withdraw(
		address to_,
		address asset_,
		uint256 valueOrId_,
		bool erc20_,
		bool toETH_
	) internal virtual;

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

	function takerMetadata(uint256 takerId_)
		public
		view
		returns (
			address maker_,
			uint256 makerId_,
			uint256 requestSkuQuantityOrId_,
			uint256 requestPriceQuantityOrId_
		)
	{
		_requireTakerId(takerId_);

		TakerContext memory taker_ = _takers[takerId_];

		maker_ = taker_.maker;
		makerId_ = taker_.makerId;
		requestSkuQuantityOrId_ = taker_.requestSkuQuantityOrId;
		requestPriceQuantityOrId_ = taker_.requestPriceQuantityOrId;
	}

	function _mintTaker(
		address depsoitFrom_,
		address maker_,
		uint256 makerId_,
		uint256 requestSkuQuantityOrId_,
		uint256 requestPriceQuantityOrId_
	) internal virtual returns (uint256 takerId_) {
		require(maker_ != address(0), 'TAKER: maker_ is address(0)');
		require(makerId_ > 0, 'TAKER: makerId_ > 0');
		require(requestSkuQuantityOrId_ > 0, 'TAKER: requestSkuQuantityOrId_ > 0');
		require(requestSkuQuantityOrId_ > 0, 'TAKER: requestSkuQuantityOrId_ > 0');

		(
			IMaker.Metadata memory metadata_,
			uint256 sentSkuQuantityOrId_,
			uint256 receivedPaymentQuantityOrId_,
			address dex_
		) = IMaker(maker_).makerMetadata(makerId_);

		_makerRestraint(metadata_);

		// calc sku/price .

		(uint256 suggestSkuQuantityOrId_, uint256 suggestPriceQuantityOrId_) = _trySwap(
			metadata_,
			sentSkuQuantityOrId_,
			receivedPaymentQuantityOrId_,
			requestSkuQuantityOrId_,
			requestPriceQuantityOrId_
		);

		_deposit(
			depsoitFrom_,
			metadata_.paymentCurrency,
			suggestPriceQuantityOrId_,
			metadata_.paymentCurrencyType == 0,
			true
		);

		takerId_ = _nextId();

		_takers[takerId_] = TakerContext(
			maker_,
			makerId_,
			suggestSkuQuantityOrId_,
			suggestPriceQuantityOrId_,
			metadata_
		);

		_takerIds.add(bytes32(takerId_));

		emit TakerMint(address(this), takerId_, suggestSkuQuantityOrId_, suggestPriceQuantityOrId_);

		ITakerReceiver(dex_).takerFrom(address(this), takerId_);
	}

	/**
	 * @dev Close taker.
	 */
	function _closeTaker(address withdrawTo_, uint256 takerId_) internal virtual {
		_requireTakerId(takerId_);

		TakerContext storage taker_ = _takers[takerId_];

		IMaker.Metadata storage maker_ = taker_.metadata;

		uint256 skuWithdraw = _receivedSkuQuantityOrIds[takerId_];

		_withdraw(withdrawTo_, maker_.sku, skuWithdraw, maker_.skuType == 0, true);

		uint256 sendPayment = _sentPaymentQuantityOrIds[takerId_];

		uint256 paymentWithdraw = taker_.requestPriceQuantityOrId - sendPayment;

		_withdraw(
			withdrawTo_,
			maker_.paymentCurrency,
			paymentWithdraw,
			maker_.paymentCurrencyType == 0,
			true
		);

		delete _takers[takerId_];
		_takerIds.remove(bytes32(takerId_));
		delete _sentPaymentQuantityOrIds[takerId_];
		delete _receivedSkuQuantityOrIds[takerId_];

		emit TakerBurn(address(this), takerId_, skuWithdraw, sendPayment);
	}

	function takerCallback(
		uint256 takerId_,
		uint256 responseSkuQuantityOrId_,
		uint256 responsePriceQuantityOrId_
	) external override {
		_requireTakerId(takerId_);

		TakerContext storage taker_ = _takers[takerId_];

		require(
			(taker_.requestPriceQuantityOrId - _sentPaymentQuantityOrIds[takerId_]) >=
				responsePriceQuantityOrId_,
			'TAKER: responsePriceQuantityOrId_ overflow or taker fullfilled'
		);

		require(msg.sender == taker_.maker);

		require(
			responseSkuQuantityOrId_ <= taker_.requestSkuQuantityOrId,
			'TAKER: responseSkuQuantityOrId_ overflow'
		);

		require(
			responsePriceQuantityOrId_ <= taker_.requestPriceQuantityOrId,
			'TAKER: responsePriceQuantityOrId_ overflow'
		);

		IMaker.Metadata storage metadata_ = taker_.metadata;

		_deposit(
			taker_.maker,
			metadata_.sku,
			responseSkuQuantityOrId_,
			metadata_.skuType == 0,
			false
		);

		_withdraw(
			taker_.maker,
			metadata_.paymentCurrency,
			responsePriceQuantityOrId_,
			metadata_.paymentCurrencyType == 0,
			true
		);

		_receivedSkuQuantityOrIds[takerId_] += responseSkuQuantityOrId_;

		_sentPaymentQuantityOrIds[takerId_] += responsePriceQuantityOrId_;
	}
}

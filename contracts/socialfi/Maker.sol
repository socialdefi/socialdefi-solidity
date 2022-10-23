// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './IDEX.sol';
import './IMaker.sol';

import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

abstract contract Maker is IMaker {
	// using Counters
	using EnumerableSet for EnumerableSet.Bytes32Set;

	/// Mapping maker id to Maker struct.
	mapping(uint256 => Metadata) private _makers;

	/// Maker id set
	EnumerableSet.Bytes32Set private _makerIds;

	/// mapping maker id to sent sku quantity or id
	mapping(uint256 => uint256) private _sentSkuQuantityOrIds;

	/// mapping maker id to received payament quantity or id
	mapping(uint256 => uint256) private _receivedPaymentQuantityOrIds;

	/// mapping maker id to approved dex;
	mapping(uint256 => address) private _approvedDexes;

	function totalSupplyOfMaker() external view returns (uint256 totalSupply_) {
		return _makerIds.length();
	}

	function makerByIndex(uint256 index_) external view returns (uint256 makerId_) {
		return uint256(_makerIds.at(index_));
	}

	function _requireMakerId(uint256 makerId_) private view {
		require(_makerIds.contains(bytes32(makerId_)), 'MAKER: maker id does not exist');
	}

	function makerMetadata(uint256 makerId_)
		public
		view
		returns (
			Metadata memory maker_,
			uint256 sentSkuQuantityOrId_,
			uint256 receivedPaymentQuantityOrId_,
			address dex_
		)
	{
		_requireMakerId(makerId_);

		maker_ = _makers[makerId_];
		sentSkuQuantityOrId_ = _sentSkuQuantityOrIds[makerId_];
		receivedPaymentQuantityOrId_ = _receivedPaymentQuantityOrIds[makerId_];
		dex_ = _approvedDexes[makerId_];
	}

	function _updateMaker(
		uint256 makerId_,
		uint256 sentSkuQuantityOrId_,
		uint256 receivedPaymentQuantityOrId_
	) internal virtual {
		_requireMakerId(makerId_);

		require(sentSkuQuantityOrId_ > 0, 'SW: sentSkuQuantityOrId_ must > 0');
		require(receivedPaymentQuantityOrId_ > 0, 'SW: receivedPaymentQuantityOrId_ must > 0');

		Metadata storage maker_ = _makers[makerId_];

		if (maker_.skuType != 0) {
			require(
				_sentSkuQuantityOrIds[makerId_] == 0 &&
					maker_.skuQuantityOrId == sentSkuQuantityOrId_,
				'MAKER: sku is erc721 token does not support partial deal'
			);
		}

		if (maker_.paymentCurrencyType != 0) {
			require(
				_receivedPaymentQuantityOrIds[makerId_] == 0 &&
					maker_.priceQuantityOrId == receivedPaymentQuantityOrId_,
				'MAKER: payment currency is erc721 token does not support partial deal'
			);
		}

		_sentSkuQuantityOrIds[makerId_] += sentSkuQuantityOrId_;

		_receivedPaymentQuantityOrIds[makerId_] += receivedPaymentQuantityOrId_;
	}

	function _listToDex(
		uint256 makerId_,
		address to_,
		uint256 fee_
	) private {
		require(makerId_ > 0, 'MAKER: maker id must > 0');
		require(to_ != address(0), 'MAKER: list to dex address is zero');

		uint256 fee = IDEX(to_).fee(address(this));

		require(fee <= fee_, 'MAKER: list dex fee insufficent');

		IDEX(to_).list{ value: fee_ }(makerId_);
	}

	function _delistFromDex(uint256 makerId_, address to_) private {
		require(makerId_ > 0, 'MAKER: maker id must > 0');
		require(to_ != address(0), 'MAKER: list to dex address is zero');

		IDEX(to_).delist(makerId_);
	}

	function approveDex(uint256 makerId_, address to_) public payable override {
		_requireMakerId(makerId_);

		address currentDex = _approvedDexes[makerId_];

		if (currentDex != address(0)) {
			_delistFromDex(makerId_, currentDex);
		}

		if (to_ != address(0)) {
			_listToDex(makerId_, to_, msg.value);
		}
	}

	/**
	 * @dev Generate next id and return.
	 */
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

	/**
	 * @dev mint new maker , and deposit asset from `depsoitFrom_`.
	 */
	function _mintMaker(
		address depsoitFrom_,
		Metadata memory maker_,
		address dex_
	) internal returns (uint256 makerId_) {
		_makerRestraint(maker_);

		uint256 fee_ = msg.value -
			_deposit(depsoitFrom_, maker_.sku, maker_.skuQuantityOrId, maker_.skuType == 0, true);

		makerId_ = _nextId();

		_makers[makerId_] = maker_;

		_makerIds.add(bytes32(makerId_));

		if (dex_ != address(0)) {
			_listToDex(makerId_, dex_, fee_);
		}

		emit MakerMint(address(this), makerId_, dex_);
	}

	/**
	 * @dev close maker and withdraw asset from this contract.
	 */
	function _closeMaker(address withdrawTo_, uint256 makerId_) internal {
		_requireMakerId(makerId_);

		Metadata storage maker_ = _makers[makerId_];

		uint256 skuWithdraw = maker_.priceQuantityOrId - _sentSkuQuantityOrIds[makerId_];

		_withdraw(withdrawTo_, maker_.sku, skuWithdraw, maker_.skuType == 0, true);

		uint256 paymentWithdraw = _receivedPaymentQuantityOrIds[makerId_];

		_withdraw(
			withdrawTo_,
			maker_.paymentCurrency,
			paymentWithdraw,
			maker_.paymentCurrencyType == 0,
			true
		);

		delete _makers[makerId_];
		_makerIds.remove(bytes32(makerId_));
		_sentSkuQuantityOrIds[makerId_];
		_receivedPaymentQuantityOrIds[makerId_];

		emit MakerBurn(address(this), makerId_);
	}
}

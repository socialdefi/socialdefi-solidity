// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './Maker.sol';
import './Taker.sol';
import './TakerReceiver.sol';
import './ISocialWallet.sol';

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

abstract contract SocialWallet is Maker, Taker, TakerReceiver, ISocialWallet {
	using SafeERC20 for IERC20;

	using Counters for Counters.Counter;

	Counters.Counter private _idgen;

	///////////////////////////////////////////////////////////////////////////////////
	// internal methods
	//
	///////////////////////////////////////////////////////////////////////////////////

	function _nextId() internal override(Maker, Taker) returns (uint256) {
		_idgen.increment();

		return _idgen.current();
	}

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
	{
		require(maker_ == address(this), "SW: only support query this contract's maker order");

		return Maker.makerMetadata(makerId_);
	}

	function _updateMaker(
		uint256 makerId_,
		uint256 sentSkuQuantityOrId_,
		uint256 receivedPaymentQuantityOrId_
	) internal override(Maker, TakerReceiver) {
		Maker._updateMaker(makerId_, sentSkuQuantityOrId_, receivedPaymentQuantityOrId_);
	}

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
		override(Taker, TakerReceiver)
		returns (uint256 suggestSkuQuantityOrId_, uint256 suggestPriceQuantityOrId_)
	{}

	function _beginInblockSwap(
		IMaker.Metadata memory metadata,
		address to_,
		uint256 approveSkuQuantityOrId_,
		uint256 expectPriceQuantityOrId_
	) internal override returns (uint256 skuQuantityOrId_, uint256 priceQuantityOrId_) {
		_makerRestraint(metadata);
		require(to_ != address(0), 'SW: inblock swap to_ address(0)');
		require(approveSkuQuantityOrId_ > 0, 'SW: inblock swap approveSkuQuantityOrId_ must > 0');
		require(expectPriceQuantityOrId_ > 0, 'SW: inblock swap expectPriceQuantityOrId_ must > 0');

		if (metadata.skuType == 0) {
			IERC20(metadata.sku).safeApprove(to_, approveSkuQuantityOrId_);
			skuQuantityOrId_ = IERC20(metadata.sku).balanceOf(address(this));
		} else {
			IERC721(metadata.sku).approve(to_, approveSkuQuantityOrId_);
			skuQuantityOrId_ = approveSkuQuantityOrId_;
		}

		if (metadata.paymentCurrencyType == 0) {
			priceQuantityOrId_ = IERC20(metadata.paymentCurrency).balanceOf(address(this));
		} else {
			require(
				IERC721(metadata.paymentCurrency).ownerOf(expectPriceQuantityOrId_) !=
					address(this),
				'SW: expectPriceQuantityOrId_ owner is self'
			);
			priceQuantityOrId_ = 0;
		}
	}

	function _endInblockSwap(
		IMaker.Metadata memory metadata,
		address to_,
		uint256 approveSkuQuantityOrId_,
		uint256 expectPriceQuantityOrId_
	) internal override returns (uint256 skuQuantityOrId_, uint256 priceQuantityOrId_) {
		_makerRestraint(metadata);
		require(to_ != address(0), 'SW: inblock swap to_ address(0)');
		require(approveSkuQuantityOrId_ > 0, 'SW: inblock swap approveSkuQuantityOrId_ must > 0');
		require(expectPriceQuantityOrId_ > 0, 'SW: inblock swap expectPriceQuantityOrId_ must > 0');

		if (metadata.skuType == 0) {
			IERC20(metadata.sku).safeApprove(to_, 0);
			skuQuantityOrId_ = IERC20(metadata.sku).balanceOf(address(this));
		} else {
			if (IERC721(metadata.sku).ownerOf(approveSkuQuantityOrId_) == address(this)) {
				skuQuantityOrId_ = approveSkuQuantityOrId_;
			} else {
				IERC721(metadata.sku).approve(address(0), approveSkuQuantityOrId_);
				skuQuantityOrId_ = 0;
			}
		}

		if (metadata.paymentCurrencyType == 0) {
			priceQuantityOrId_ = IERC20(metadata.paymentCurrency).balanceOf(address(this));
		} else {
			if (
				IERC721(metadata.paymentCurrency).ownerOf(expectPriceQuantityOrId_) == address(this)
			) {
				priceQuantityOrId_ = expectPriceQuantityOrId_;
			} else {
				priceQuantityOrId_ = 0;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////////
	// external / public methods
	//
	///////////////////////////////////////////////////////////////////////////////////

	/**
	 * @dev  IERC165#supportsInterface implementation
	 */
	function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
		return
			type(IMaker).interfaceId == interfaceId ||
			type(ITaker).interfaceId == interfaceId ||
			type(ITakerReceiver).interfaceId == interfaceId;
	}
}

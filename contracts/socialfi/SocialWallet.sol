// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './Maker.sol';
import './Taker.sol';
import '../token/IWETH.sol';
import './TakerReceiver.sol';
import './ISocialWallet.sol';

import 'hardhat/console.sol';

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';

abstract contract SocialWallet is ERC721Holder, Maker, Taker, TakerReceiver, ISocialWallet {
	using SafeERC20 for IERC20;

	using EnumerableSet for EnumerableSet.Bytes32Set;

	using Counters for Counters.Counter;

	Counters.Counter private _idgen;

	address public immutable _WETH;

	constructor(address WETH_) {
		require(WETH_ != address(0), 'SW: WETH_ must be provided');

		_WETH = WETH_;
	}

	///////////////////////////////////////////////////////////////////////////////////
	// internal methods
	//
	///////////////////////////////////////////////////////////////////////////////////

	function _nextId() internal override(Maker, Taker) returns (uint256) {
		_idgen.increment();

		return _idgen.current();
	}

	function _makerRestraint(IMaker.Metadata memory maker_) internal view override(Maker, Taker) {
		require(maker_.sku != address(0), 'SW: SKU address is zero');
		require(maker_.skuQuantityOrId > 0, 'SW: skuQuantityOrId > 0');
		require(maker_.paymentCurrency != address(0), 'SW: payment currency address is zero');
		require(maker_.priceQuantityOrId > 0, 'SW: priceQuantityOrId > 0');

		if (maker_.skuType != 0) {
			require(
				IERC165(maker_.sku).supportsInterface(type(IERC721).interfaceId),
				'SW: check maker sku type(erc721) failed'
			);
		}

		if (maker_.paymentCurrencyType != 0) {
			require(
				IERC165(maker_.sku).supportsInterface(type(IERC721).interfaceId),
				'SW: check maker payment currency type(erc721) failed'
			);
		}
	}

	function _deposit(
		address from_,
		address asset_,
		uint256 valueOrId_,
		bool erc20_,
		bool fromETH_
	) internal override(Maker, Taker) returns (uint256 depositETH_) {
		require(from_ != address(0), 'SW: invalid param _deposit#from_');
		require(asset_ != address(0), 'SW: invalid param _deposit#asset_');
		require(valueOrId_ > 0, 'SW: invalid param _deposit#valueOrId_ ');

		if (asset_ == _WETH) {
			require(erc20_, 'FZWT: WETH is erc20 token');

			if (fromETH_) {
				require(
					msg.value >= valueOrId_,
					'FZWT: deposit native token with insufficent payment.'
				);
				// native token deposit, try convert to WETH token.

				// WETH deposit check
				uint256 balance = IERC20(asset_).balanceOf(address(this));

				IWETH(asset_).deposit{ value: valueOrId_ }();

				require(
					(balance + valueOrId_) == IERC20(asset_).balanceOf(address(this)),
					'FZWT: WETH deposit failed'
				);

				depositETH_ = valueOrId_;

				return depositETH_;
			}
		}

		if (erc20_) {
			IERC20(asset_).safeTransferFrom(from_, address(this), valueOrId_);
		} else {
			IERC721(asset_).safeTransferFrom(from_, address(this), valueOrId_);
		}
	}

	function _withdraw(
		address to_,
		address asset_,
		uint256 valueOrId_,
		bool erc20_,
		bool toETH_
	) internal override(Maker, Taker) {
		require(to_ != address(0), 'SW: invalid param _withdraw#recipent_');
		require(asset_ != address(0), 'SW: invalid param _withdraw#asset_');
		require(valueOrId_ > 0, 'SW: invalid param _withdraw#valueOrId_ ');

		if (asset_ == _WETH) {
			require(erc20_, 'FZWT: WETH is erc20 token');

			if (toETH_) {
				// native token deposit, try convert to WETH token.

				// WETH deposit check
				uint256 balance = address(this).balance;

				IWETH(asset_).withdraw(valueOrId_);

				require(
					(balance + valueOrId_) == address(this).balance,
					'FZWT: WETH withdraw failed'
				);

				payable(to_).transfer(valueOrId_);

				return;
			}
		}

		if (erc20_) {
			IERC20(asset_).safeTransfer(to_, valueOrId_);
		} else {
			IERC721(asset_).safeTransferFrom(address(this), to_, valueOrId_);
		}
	}

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
	{
		require(requestSkuQuantityOrId_ > 0, 'SW: inblock swap requestSkuQuantityOrId_ must > 0');
		require(
			requestPriceQuantityOrId_ > 0,
			'SW: inblock swap requestPriceQuantityOrId_ must > 0'
		);

		if (metadata.skuType == 0 && metadata.paymentCurrencyType == 0) {
			suggestSkuQuantityOrId_ = metadata.skuQuantityOrId - sentSkuQuantityOrId_;

			if (requestSkuQuantityOrId_ < suggestSkuQuantityOrId_) {
				suggestSkuQuantityOrId_ = requestSkuQuantityOrId_;
			}

			suggestPriceQuantityOrId_ =
				(metadata.priceQuantityOrId * suggestSkuQuantityOrId_) /
				metadata.skuQuantityOrId;

			require(
				suggestPriceQuantityOrId_ >= requestPriceQuantityOrId_,
				'SW: insufficent requestPriceQuantityOrId_'
			);
		} else {
			require(
				sentSkuQuantityOrId_ == 0,
				'SW: trading pair including erc721 token does not support partial deal'
			);
			require(
				receivedPaymentQuantityOrId_ == 0,
				'SW:  trading pair including erc721 token does not support partial deal'
			);

			suggestSkuQuantityOrId_ = metadata.skuQuantityOrId;
			suggestPriceQuantityOrId_ = metadata.priceQuantityOrId;

			require(
				requestSkuQuantityOrId_ == suggestSkuQuantityOrId_,
				'SW: trading pair including erc721 token does not support partial deal'
			);
			require(
				requestPriceQuantityOrId_ == suggestPriceQuantityOrId_,
				'SW:  trading pair including erc721 token does not support partial deal'
			);
		}
	}

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

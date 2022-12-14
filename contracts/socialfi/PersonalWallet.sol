// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './SocialWallet.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract PersonalWallet is SocialWallet, Ownable, ReentrancyGuard {
	constructor(address WETH_) SocialWallet(WETH_) {}

	/**
	 * @dev Mint new maker order.
	 */
	function mintMaker(IMaker.Metadata memory maker_, address dex_)
		external
		payable
		override
		onlyOwner
		nonReentrant
		returns (uint256 makerId_)
	{
		return _mintMaker(msg.sender, maker_, dex_);
	}

	/**
	 * @dev Close maker.
	 */
	function closeMaker(uint256 makerId_) external override onlyOwner nonReentrant {
		_closeMaker(msg.sender, makerId_);
	}

	/**
	 * @dev mint new taker order.
	 */
	function mintTaker(
		address maker_,
		uint256 makerId_,
		uint256 requestSkuQuantityOrId_,
		uint256 requestPriceQuantityOrId_
	) external payable override onlyOwner nonReentrant returns (uint256 takerId_) {
		return
			_mintTaker(
				msg.sender,
				maker_,
				makerId_,
				requestSkuQuantityOrId_,
				requestPriceQuantityOrId_
			);
	}

	/**
	 * @dev Close taker.
	 */
	function closeTaker(uint256 takerId_) external override onlyOwner nonReentrant {
		_closeTaker(msg.sender, takerId_);
	}
}

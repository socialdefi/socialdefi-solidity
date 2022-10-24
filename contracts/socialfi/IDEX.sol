// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './ITakerReceiver.sol';

interface IDEX is ITakerReceiver {
	function list(uint256 tokenId_) external payable;

	function delist(uint256 tokenId_) external;

	function fee(address from_) external view returns (uint256 listFee_);
}

// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import './IDEX.sol';
import './IMaker.sol';
import './ITaker.sol';

import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

contract SFIStore is IDEX {
	// using Counters
	using EnumerableSet for EnumerableSet.Bytes32Set;

	uint256 private immutable _listFee;

	mapping(address => EnumerableSet.Bytes32Set) private _makerIds;

	constructor(uint256 FEE_) {
		_listFee = FEE_;
	}

	function list(uint256 tokenId_) external payable {
		require(msg.value >= _listFee, 'SFIDEX');

		_makerIds[msg.sender].add(bytes32(tokenId_));
	}

	function delist(uint256 tokenId_) external {
		_makerIds[msg.sender].remove(bytes32(tokenId_));
	}

	function fee(address) external view returns (uint256 listFee_) {
		return _listFee;
	}

	function takerFrom(address from_, uint256 takerId_) external {
		(address maker_, uint256 makerId_, , ) = ITaker(from_).takerMetadata(takerId_);

		ITakerReceiver(maker_).takerFrom(from_, makerId_);
	}
}

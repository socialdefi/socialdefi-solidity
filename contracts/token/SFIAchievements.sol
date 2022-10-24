// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract SFIAToken is ERC721Enumerable, Ownable {
	using Counters for Counters.Counter;

	Counters.Counter private _idgen;

	mapping(uint256 => uint256) private _actievementTypes;

	constructor() ERC721('SFIA', 'SocialFi Achievements') {}

	function mint(address recipent_, uint256 actievementType_)
		public
		onlyOwner
		returns (uint256 tokenId_)
	{
		_idgen.increment();

		tokenId_ = _idgen.current();

		_actievementTypes[tokenId_] = actievementType_;

		_safeMint(recipent_, tokenId_);
	}

	function burn(uint256 tokenId_) public onlyOwner {
		_burn(tokenId_);
		delete _actievementTypes[tokenId_];
	}
}

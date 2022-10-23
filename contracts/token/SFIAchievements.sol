// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract SFIToken is ERC721Enumerable, Ownable {
	constructor() ERC721('SFIA', 'SocialFi Achievements') {}
}

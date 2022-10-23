// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract SFIToken is ERC20, Ownable {
	constructor() ERC20('SFI', 'SocialFi Token') {
		// mint 21,100,000
		_mint(owner(), 2100 * 10**5 * 10**18);
	}
}

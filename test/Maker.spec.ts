import 'hardhat';
import '@typechain/hardhat';
import '@nomicfoundation/hardhat-chai-matchers';

import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

import { Deployer } from '../scripts';
import { PersonalWallet, PersonalWallet__factory } from '../src/types';

import { expect } from 'chai';

describe('Maker contract tests', async () => {
	let s1: SignerWithAddress;
	let s2: SignerWithAddress;
	let s3: SignerWithAddress;
	let wallet: PersonalWallet;

	let WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';

	beforeEach(async () => {
		[s1, s2, s3] = await ethers.getSigners();

		const deployer = new Deployer();

		wallet = await deployer.deploy('PersonalWallet', [WETH]);
	});
});

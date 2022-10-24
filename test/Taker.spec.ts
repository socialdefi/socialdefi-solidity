import 'hardhat';
import '@typechain/hardhat';
import '@nomicfoundation/hardhat-chai-matchers';

import { anyValue } from '@nomicfoundation/hardhat-chai-matchers/withArgs';

import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

import { Deployer } from '../scripts';
import { PersonalWallet, SFIToken, SFIAToken, IDEX } from '../src/types';

import { expect } from 'chai';
import { BigNumber } from 'ethers';

describe('Taker contract tests', async () => {
	let s1: SignerWithAddress;
	let s2: SignerWithAddress;
	let s3: SignerWithAddress;
	let maker: PersonalWallet;
	let taker: PersonalWallet;
	let erc20Token: SFIToken;
	let erc721Token: SFIAToken;
	let dex: IDEX;

	let listFee = BigNumber.from(10).pow(18).mul(1);

	let priceOrId = BigNumber.from(1).mul(BigNumber.from(10).pow(18));

	let WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';

	beforeEach(async () => {
		[s1, s2, s3] = await ethers.getSigners();

		const deployer = new Deployer();

		maker = await deployer.deploy('PersonalWallet', [WETH]);

		taker = await deployer.deploy('PersonalWallet', [WETH]);

		erc20Token = await deployer.deploy('SFIToken', []);

		erc721Token = await deployer.deploy('SFIAToken', []);

		dex = await deployer.deploy('SFIStore', [listFee]);
	});

	const createMaker = async () => {
		await expect(erc721Token.mint(s1.address, 1))
			.to.be.emit(erc721Token, 'Transfer')
			.withArgs(ethers.constants.AddressZero, s1.address, anyValue);

		const balance = await erc721Token.balanceOf(s1.address);

		await expect(erc721Token.approve(maker.address, balance))
			.to.be.emit(erc721Token, 'Approval')
			.withArgs(s1.address, maker.address, balance);

		// Create new maker order
		await expect(
			maker.mintMaker(
				{
					sku: erc721Token.address,
					skuQuantityOrId: balance,
					paymentCurrency: WETH,
					priceQuantityOrId: priceOrId,
					skuType: 1,
					paymentCurrencyType: 0,
				},
				ethers.constants.AddressZero,
				{
					value: priceOrId,
				},
			),
		)
			.to.be.emit(maker, 'MakerMint')
			.withArgs(maker.address, anyValue, anyValue)
			.to.be.not.emit(maker, 'List');
	};

	it('Create new taker', async () => {
		await expect(erc721Token.mint(s1.address, 1))
			.to.be.emit(erc721Token, 'Transfer')
			.withArgs(ethers.constants.AddressZero, s1.address, anyValue);

		const balance = await erc721Token.balanceOf(s1.address);

		await expect(erc721Token.approve(maker.address, balance))
			.to.be.emit(erc721Token, 'Approval')
			.withArgs(s1.address, maker.address, balance);

		// Create new maker order
		await expect(
			maker.mintMaker(
				{
					sku: erc721Token.address,
					skuQuantityOrId: balance,
					paymentCurrency: WETH,
					priceQuantityOrId: priceOrId,
					skuType: 1,
					paymentCurrencyType: 0,
				},
				ethers.constants.AddressZero,
				{
					value: priceOrId,
				},
			),
		)
			.to.be.emit(maker, 'MakerMint')
			.withArgs(maker.address, anyValue, anyValue)
			.to.be.not.emit(maker, 'List');

		await expect(taker.mintTaker(maker.address, 1, 1, priceOrId, { value: priceOrId }))
			.to.be.emit(taker, 'TakerMint')
			.withArgs(taker.address, anyValue, 1, priceOrId);
	});
});

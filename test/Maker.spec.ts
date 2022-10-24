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

describe('Maker contract tests', async () => {
	let s1: SignerWithAddress;
	let s2: SignerWithAddress;
	let s3: SignerWithAddress;
	let wallet: PersonalWallet;
	let erc20Token: SFIToken;
	let erc721Token: SFIAToken;
	let dex: IDEX;

	let listFee = BigNumber.from(10).pow(18).mul(1);

	let WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';

	beforeEach(async () => {
		[s1, s2, s3] = await ethers.getSigners();

		const deployer = new Deployer();

		wallet = await deployer.deploy('PersonalWallet', [WETH]);

		erc20Token = await deployer.deploy('SFIToken', []);

		erc721Token = await deployer.deploy('SFIAToken', []);

		dex = await deployer.deploy('SFIStore', [listFee]);
	});

	it('New maker test', async () => {
		// prepare tokens
		await expect(erc721Token.mint(s1.address, 1)).to.be.emit(erc721Token, 'Transfer');

		// approve transfer
		await expect(erc721Token.approve(wallet.address, 1))
			.to.be.emit(erc721Token, 'Approval')
			.withArgs(s1.address, wallet.address, 1);

		// Create new maker order
		await expect(
			wallet.mintMaker(
				{
					sku: erc721Token.address,
					skuQuantityOrId: 1,
					paymentCurrency: erc20Token.address,
					priceQuantityOrId: BigNumber.from(2100).mul(BigNumber.from(10).pow(18)),
					skuType: 1,
					paymentCurrencyType: 0,
				},
				ethers.constants.AddressZero,
			),
		)
			.to.be.emit(wallet, 'MakerMint')
			.withArgs(wallet.address, 1, anyValue)
			.to.changeTokenBalance(erc721Token, s1.address, -1);

		await expect(wallet.closeMaker(1))
			.to.be.emit(wallet, 'MakerBurn')
			.to.changeTokenBalance(erc721Token, s1.address, 1);
	});

	it('Maker with insufficent allowance', async () => {
		const expectTokenAmount = BigNumber.from(10).pow(18).mul(1000);

		const approvedTokenAmount = expectTokenAmount.sub(2);

		// approve transfer
		await expect(erc20Token.approve(wallet.address, approvedTokenAmount))
			.to.be.emit(erc20Token, 'Approval')
			.withArgs(s1.address, wallet.address, approvedTokenAmount);

		// Create new maker order
		await expect(
			wallet.mintMaker(
				{
					sku: erc20Token.address,
					skuQuantityOrId: expectTokenAmount,
					paymentCurrency: WETH,
					priceQuantityOrId: BigNumber.from(1).mul(BigNumber.from(10).pow(18)),
					skuType: 0,
					paymentCurrencyType: 0,
				},
				ethers.constants.AddressZero,
			),
		).to.be.revertedWith('ERC20: insufficient allowance');
	});

	it('Maker with insufficent allowance 2', async () => {
		const expectTokenAmount = BigNumber.from(10).pow(18).mul(1000);

		// approve transfer
		await expect(erc20Token.approve(wallet.address, expectTokenAmount))
			.to.be.emit(erc20Token, 'Approval')
			.withArgs(s1.address, wallet.address, expectTokenAmount);

		await expect(
			wallet.mintMaker(
				{
					sku: erc20Token.address,
					skuQuantityOrId: expectTokenAmount,
					paymentCurrency: WETH,
					priceQuantityOrId: BigNumber.from(1).mul(BigNumber.from(10).pow(18)),
					skuType: 0,
					paymentCurrencyType: 0,
				},
				ethers.constants.AddressZero,
			),
		)
			.to.be.emit(wallet, 'MakerMint')
			.withArgs(wallet.address, 1, anyValue)
			.to.changeTokenBalance(erc20Token, wallet.address, expectTokenAmount);

		// Create new maker order
		await expect(
			wallet.mintMaker(
				{
					sku: erc20Token.address,
					skuQuantityOrId: expectTokenAmount,
					paymentCurrency: WETH,
					priceQuantityOrId: BigNumber.from(1).mul(BigNumber.from(10).pow(18)),
					skuType: 0,
					paymentCurrencyType: 0,
				},
				ethers.constants.AddressZero,
			),
		).to.be.revertedWith('ERC20: insufficient allowance');
	});

	it('Direct deposit lost!!!!!', async () => {
		const expectTokenAmount = BigNumber.from(10).pow(18).mul(1000);

		// approve transfer
		await expect(erc20Token.approve(wallet.address, expectTokenAmount))
			.to.be.emit(erc20Token, 'Approval')
			.withArgs(s1.address, wallet.address, expectTokenAmount);

		await expect(erc20Token.transfer(wallet.address, expectTokenAmount))
			.to.be.emit(erc20Token, 'Transfer')
			.withArgs(s1.address, wallet.address, expectTokenAmount);

		// Create new maker order
		await expect(
			wallet.mintMaker(
				{
					sku: erc20Token.address,
					skuQuantityOrId: expectTokenAmount,
					paymentCurrency: WETH,
					priceQuantityOrId: BigNumber.from(1).mul(BigNumber.from(10).pow(18)),
					skuType: 0,
					paymentCurrencyType: 0,
				},
				ethers.constants.AddressZero,
			),
		)
			.to.be.emit(wallet, 'MakerMint')
			.withArgs(wallet.address, 1, anyValue)
			.to.changeTokenBalance(erc20Token, wallet.address, expectTokenAmount);

		await expect(wallet.closeMaker(1))
			.to.be.emit(wallet, 'MakerBurn')
			.to.changeTokenBalance(erc20Token, s1.address, expectTokenAmount);
	});

	it('List maker', async () => {
		const expectTokenAmount = BigNumber.from(10).pow(18).mul(1000);

		// approve transfer
		await expect(erc20Token.approve(wallet.address, expectTokenAmount))
			.to.be.emit(erc20Token, 'Approval')
			.withArgs(s1.address, wallet.address, expectTokenAmount);

		// Create new maker order
		await expect(
			wallet.mintMaker(
				{
					sku: erc20Token.address,
					skuQuantityOrId: expectTokenAmount,
					paymentCurrency: WETH,
					priceQuantityOrId: BigNumber.from(1).mul(BigNumber.from(10).pow(18)),
					skuType: 0,
					paymentCurrencyType: 0,
				},
				dex.address,
				{
					value: listFee, // payment
				},
			),
		)
			.to.be.emit(wallet, 'MakerMint')
			.withArgs(wallet.address, 1, anyValue)
			.to.changeTokenBalance(erc20Token, wallet.address, expectTokenAmount)
			.to.be.emit(wallet, 'List')
			.withArgs(wallet.address, 1, dex.address);

		await expect(wallet.closeMaker(1))
			.to.be.emit(wallet, 'MakerBurn')
			.to.changeTokenBalance(erc20Token, s1.address, expectTokenAmount)
			.to.be.emit(wallet, 'Delist')
			.withArgs(wallet.address, 1, dex.address);
	});

	it('Change list dex', async () => {
		let dex2 = await new Deployer().deploy('SFIStore', [listFee]);

		const expectTokenAmount = BigNumber.from(10).pow(18).mul(1000);

		// approve transfer
		await expect(erc20Token.approve(wallet.address, expectTokenAmount))
			.to.be.emit(erc20Token, 'Approval')
			.withArgs(s1.address, wallet.address, expectTokenAmount);

		// Create new maker order
		await expect(
			wallet.mintMaker(
				{
					sku: erc20Token.address,
					skuQuantityOrId: expectTokenAmount,
					paymentCurrency: WETH,
					priceQuantityOrId: BigNumber.from(1).mul(BigNumber.from(10).pow(18)),
					skuType: 0,
					paymentCurrencyType: 0,
				},
				dex.address,
				{
					value: listFee, // payment
				},
			),
		)
			.to.be.emit(wallet, 'MakerMint')
			.withArgs(wallet.address, 1, anyValue)
			.to.changeTokenBalance(erc20Token, wallet.address, expectTokenAmount)
			.to.be.emit(wallet, 'List')
			.withArgs(wallet.address, 1, dex.address);

		await expect(
			wallet.approveDex(1, dex2.address, {
				value: listFee, // payment
			}),
		)
			.to.be.emit(wallet, 'Delist')
			.withArgs(wallet.address, 1, dex.address)
			.to.be.emit(wallet, 'List')
			.withArgs(wallet.address, 1, dex2.address);

		await expect(wallet.closeMaker(1))
			.to.be.emit(wallet, 'MakerBurn')
			.to.changeTokenBalance(erc20Token, s1.address, expectTokenAmount)
			.to.be.emit(wallet, 'Delist')
			.withArgs(wallet.address, 1, dex2.address);
	});

	it('Delist dex', async () => {
		const expectTokenAmount = BigNumber.from(10).pow(18).mul(1000);

		// approve transfer
		await expect(erc20Token.approve(wallet.address, expectTokenAmount))
			.to.be.emit(erc20Token, 'Approval')
			.withArgs(s1.address, wallet.address, expectTokenAmount);

		// Create new maker order
		await expect(
			wallet.mintMaker(
				{
					sku: erc20Token.address,
					skuQuantityOrId: expectTokenAmount,
					paymentCurrency: WETH,
					priceQuantityOrId: BigNumber.from(1).mul(BigNumber.from(10).pow(18)),
					skuType: 0,
					paymentCurrencyType: 0,
				},
				dex.address,
				{
					value: listFee, // payment
				},
			),
		)
			.to.be.emit(wallet, 'MakerMint')
			.withArgs(wallet.address, 1, anyValue)
			.to.changeTokenBalance(erc20Token, wallet.address, expectTokenAmount)
			.to.be.emit(wallet, 'List')
			.withArgs(wallet.address, 1, dex.address);

		await expect(wallet.approveDex(1, ethers.constants.AddressZero))
			.to.be.emit(wallet, 'Delist')
			.withArgs(wallet.address, 1, dex.address);

		await expect(wallet.closeMaker(1))
			.to.be.emit(wallet, 'MakerBurn')
			.to.changeTokenBalance(erc20Token, s1.address, expectTokenAmount)
			.to.be.not.emit(wallet, 'Delist');
	});

	it('Maker forech', async () => {
		const expectTokenAmount = BigNumber.from(10).pow(18).mul(1000);

		const createMaker = async () => {
			// approve transfer
			await expect(erc20Token.approve(wallet.address, expectTokenAmount))
				.to.be.emit(erc20Token, 'Approval')
				.withArgs(s1.address, wallet.address, expectTokenAmount);

			// Create new maker order
			await expect(
				wallet.mintMaker(
					{
						sku: erc20Token.address,
						skuQuantityOrId: expectTokenAmount,
						paymentCurrency: WETH,
						priceQuantityOrId: BigNumber.from(1).mul(BigNumber.from(10).pow(18)),
						skuType: 0,
						paymentCurrencyType: 0,
					},
					dex.address,
					{
						value: listFee, // payment
					},
				),
			)
				.to.be.emit(wallet, 'MakerMint')
				.withArgs(wallet.address, anyValue, anyValue)
				.to.changeTokenBalance(erc20Token, wallet.address, expectTokenAmount)
				.to.be.emit(wallet, 'List')
				.withArgs(wallet.address, anyValue, dex.address);
		};

		for (let i = 0; i < 20; i++) {
			await createMaker();
		}

		expect(await wallet.totalSupplyOfMaker()).to.be.equal(20);

		for (let i = 0; i < 20; i++) {
			const id = await wallet.makerByIndex(i);

			await wallet.makerMetadata(id);
		}

		while ((await wallet.totalSupplyOfMaker()).gt(0)) {
			const id = await wallet.makerByIndex(0);
			await expect(wallet.closeMaker(id))
				.to.be.emit(wallet, 'MakerBurn')
				.to.changeTokenBalance(erc20Token, s1.address, expectTokenAmount)
				.to.be.emit(wallet, 'Delist')
				.withArgs(wallet.address, id, dex.address);
		}
	});
});

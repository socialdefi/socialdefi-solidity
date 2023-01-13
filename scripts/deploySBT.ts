import { Deployer } from './deploy';
import { ethers } from 'hardhat';

async function main() {
	const Wallet = await ethers.getContractFactory('PersonalWallet');

	// const sbt = await deploy.deploy('PersonalWallet', [
	// 	'0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
	// ]);

	const wallet = await Wallet.deploy('0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2');

	await wallet.deployed();

	process.exit(0);
}

main()
	.then(() => {})
	.catch(e => console.log(e));

import { task } from 'hardhat/config';
import { HardhatUserConfig } from 'hardhat/config';

import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-ganache';
import '@nomicfoundation/hardhat-chai-matchers';

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (args, hre) => {
	const accounts = await hre.ethers.getSigners();

	for (const account of accounts) {
		console.log(account.address);
	}
});

const config: HardhatUserConfig = {
	networks: {
		hardhat: {
			mining: {
				interval: 4000,
			},
			forking: {
				url: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY as string}`,
				blockNumber: 15788498,
			},
			loggingEnabled: true,
		},
	},
	solidity: {
		version: '0.8.9',
		settings: {
			optimizer: {
				enabled: true,
				runs: 1000,
			},
		},
	},
	mocha: {
		timeout: 100000000,
	},
	typechain: {
		outDir: 'src/types',
		target: 'ethers-v5',
	},
};

export default config;

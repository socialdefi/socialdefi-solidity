import { Contract } from 'ethers';
import { Libraries } from 'hardhat/types/runtime';

import { ethers } from 'hardhat';

async function deploy<C extends Contract>(
	nameOrPath: string,
	libraries?: Libraries,
	args?: Array<any>,
	overrides?: any,
): Promise<C> {
	if (!args) {
		args = [];
	}

	if (!overrides) {
		overrides = {};
	}

	if (libraries) {
		const factory = await ethers.getContractFactory(nameOrPath, {
			libraries: libraries,
		});

		return (await factory.deploy(...args, overrides)) as C;
	} else {
		const factory = await ethers.getContractFactory(nameOrPath);

		return (await factory.deploy(...args, overrides)) as C;
	}
}
/**
 * @dev contract deploy helper class
 */
export class Deployer {
	private libraries = new Map<string, string>();

	private async linkTo(name: string): Promise<string> {
		if (this.libraries.has(name)) {
			return this.libraries.get(name)!;
		} else {
			const library = await deploy(name);

			this.libraries.set(name, library.address);

			return library.address;
		}
	}

	public async deploy<C extends Contract>(
		nameOrPath: string,
		args?: Array<any>,
		libraries?: string[],
		overrides?: any,
	): Promise<C> {
		let links: Libraries | undefined;

		if (libraries) {
			links = {};
			for (const lib of libraries) {
				links[lib] = await this.linkTo(lib);
			}
		}

		if (!args) {
			args = [];
		}

		return await deploy(nameOrPath, links, args, overrides);
	}
}

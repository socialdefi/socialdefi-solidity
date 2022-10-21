import { randomInt } from 'crypto';
import { BigNumber, BigNumberish } from 'ethers';
import { ethers } from 'ethers';

export function randomSWT(): BigNumber {
	return BigNumber.from(randomInt(10000)).mul(BigNumber.from(10).pow(18));
}

export function randomETH(): BigNumber {
	return BigNumber.from(randomInt(1000000)).mul(BigNumber.from(10).pow(14));
}

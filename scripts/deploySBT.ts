import { Deployer } from './deploy';
import hre from 'hardhat';

async function main() {
	await hre.run('compile');

	const deploy = new Deployer();

	const sbt = await deploy.deploy('SBTFactory', []);

	console.log('deply sbt', sbt.address);

	process.exit(0);
}

main()
	.then(() => {})
	.catch(e => console.log(e));

require('dotenv').config();
require("colors")
const fs = require("fs")

const jsonFile = __dirname + '/../../deployed/explorer/contracts.json';

async function main() {
	var [deployer] = await ethers.getSigners();
	console.log("deployer", deployer.address);

	console.log("deploying SCoin");
	const SCoin = await ethers.getContractFactory("SCoin");
	const sCoin = await SCoin.deploy();
	await sCoin.deployed();
	console.log("\t SCoin : ", sCoin.address);

	console.log("deploying StakeTokenizer");
	const StakeTokenizer = await ethers.getContractFactory("StakeTokenizer");
	const stakeTokenizer = await StakeTokenizer.deploy(sCoin.address);
	await stakeTokenizer.deployed();
	console.log("\t StakeTokenizer : ", stakeTokenizer.address);
	
	console.log("trying to run 'addMinter' to sCoin");
	let tx = await sCoin.addMinter(stakeTokenizer.address);
	await tx.wait();
	console.log("\t addMinter success");

	
	console.log("deploying StakerInfo");
	const StakerInfo = await ethers.getContractFactory("StakerInfo");
	const stakerInfo = await StakerInfo.deploy();
	await stakerInfo.deployed();
	console.log("\t StakerInfo : ", stakerInfo.address);
		

	fs.writeFileSync(jsonFile, JSON.stringify({
		SCoin: sCoin.address,
		StakeTokenizer: stakeTokenizer.address,
		StakerInfo: stakerInfo.address,
	}))
}

main().then(() => console.log("complete".green)).catch((error) => {console.error(error);process.exit(1);});

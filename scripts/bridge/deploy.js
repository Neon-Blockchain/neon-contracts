require('dotenv').config();
require('colors');
const fs = require('fs');
// const hre = require("hardhat");
const testnet = process.env.TESTNET==="1"
const symbol = process.env.SYMBOL

const configFile = __dirname + '/../src/config/networks' + (testnet ? '.testnet' : '') + '.json'

const networks = require(configFile);




async function main() {
	const peggingTokens = []
	{ // collecting token list
		const _tokens = {}
		for (let chain in networks) {
			if (chain!==symbol) {
				_tokens[chain] = true;
				for (let k in networks[chain].tokens) {
					if (k!==symbol) {
						_tokens[k] = true;
					}
				}
			}
		}
		for (let k in _tokens) peggingTokens.push(k);
	}

	const admin = process.env.ADMIN_PUBKEY;
	const signer = await ethers.getSigner();
	console.log(`Starting ${symbol} deploy by ${signer.address.yellow}`);
	const Bridge = await ethers.getContractFactory("Bridge");
	const bridge = await Bridge.deploy(admin);
	await bridge.deployed();
	console.log('Bridge ' + bridge.address);

	const tokens = {}
	for (let k of peggingTokens) {
		const Token = await ethers.getContractFactory('Token');
		const decimals = 18;
		const label = "Pegged " + k;
		const token = await Token.deploy(label, k, 18, bridge.address, 0);
		await token.deployed();
		console.log(label + ' ' + token.address);
		const tx2 = await bridge.addToken(token.address)
		await tx2.wait()
		tokens[k] = {
			label,
			contract: token.address,
			decimals,
			pegging: true
		}
	}

	fs.writeFileSync(configFile, JSON.stringify({
		...networks, 
		[symbol]: {
			...networks[symbol],
			bridge: bridge.address,
			tokens: {
				...networks[symbol].tokens,
				...tokens
			}
		}
	}, null, '\t'));
	console.log('contract deploy completed')
}

main().then(() => {
}).catch((error) => {
	console.error(error);
	process.exit(1);
});

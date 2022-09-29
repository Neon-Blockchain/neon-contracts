const other = require('./other')
async function main() {
	return other('ETH')
}

main().then(() => {
}).catch((error) => {
	console.error(error);
	process.exit(1);
});

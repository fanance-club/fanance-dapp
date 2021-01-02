const TokenGenerator = artifacts.require("TokenGenerator");
const CelebrityOwnerToken = artifacts.require("CelebrityOwnerToken");
const FANCToken = artifacts.require("FANCToken");
const FANCTokenICO = artifacts.require("FANCTokenICO");
const Oracle = artifacts.require("Oracle");
const CelebrityExchange = artifacts.require("CelebrityExchange");
const WETHToken = artifacts.require("WETHToken");

module.exports = async (deployer, network, accounts) => {
	let zeroAddress = "0x0000000000000000000000000000000000000000";
	let treasuryAddress = "0xF08f8261d04a08c1fe0fA4653661809775C9DC08";
	let founderAddress = "0xF08f8261d04a08c1fe0fA4653661809775C9DC08";
	let wethAddress;
	if (network == "rinkeby") {
		wethAddress = "0xc778417e063141139fce010982780140aa0cd5ab"; // rinkeby Weth
	}
	if (network == "matic") {
		wethAddress = "0x4DfAe612aaCB5b448C12A591cD0879bFa2e51d62"; // Matic Weth
	}
	if (network == "develop") {
		wethAddress = "0x0000000000000000000000000000000000000000"; // Matic Weth
	}
	let onePercent = 10 ** 16;
	let pointOneEther = 10 ** 6; // contract multiplies this by 10**10
	let twentyFivePercent = 25 * 10 ** 16;
	let twentyPercent = 20 * 10 ** 16;
	let oneMillion = 10 ** 6;
	await deployer.deploy(
		CelebrityOwnerToken,
		"Fanance Club Celebrity Ownership NFT Token",
		"FANC-NFT"
	);
	await deployer.deploy(
		FANCToken,
		"FANC Token",
		"FANC",
		oneMillion.toString(),
		zeroAddress,
		zeroAddress,
		zeroAddress
	);
	await deployer.deploy(
		FANCTokenICO,
		FANCToken.address,
		wethAddress,
		treasuryAddress
	);
	await deployer.deploy(
		Oracle,
		FANCToken.address,
		FANCTokenICO.address,
		zeroAddress,
		zeroAddress
	);
	await deployer.deploy(
		CelebrityExchange,
		onePercent.toString(),
		FANCToken.address,
		wethAddress,
		CelebrityOwnerToken.address,
		Oracle.address,
		twentyFivePercent.toString(),
		twentyPercent.toString(),
		pointOneEther
	);
	await deployer.deploy(
		TokenGenerator,
		CelebrityOwnerToken.address,
		CelebrityExchange.address,
		treasuryAddress,
		founderAddress,
		10,
		10,
		10
	);
	// const tokenGenerator = await TokenGenerator.deployed();
	// await tokenGenerator.setDetails(
	// 	CelebrityOwnerToken.address,
	// 	CelebrityExchange.address,
	// 	treasuryAddress,
	// 	founderAddress,
	// 	10,
	// 	10,
	// 	10,
	// 	{ from: accounts[0] }
	// );
	const fanToken = await FANCToken.deployed();
	await fanToken.changeExchangeAddresses(
		CelebrityExchange.address,
		treasuryAddress,
		FANCTokenICO.address,
		{ from: accounts[0] }
	);
	// const celebrityOwnerToken = await CelebrityOwnerToken.deployed();
	// await celebrityOwnerToken.transferOwnership(TokenGenerator.address, {
	// 	from: accounts[0],
	// });
	// await WETHToken(wethAddress).approve(
	// 	CelebrityExchange.address,
	// 	100 * (10 ^ 18),
	// 	{ from: accounts[0] }
	// );
	// await WETHToken(wethAddress).approve(
	// 	CelebrityExchange.address,
	// 	100 * (10 ^ 18),
	// 	{ from: accounts[1] }
	// );
	// await WETHToken(wethAddress).approve(
	// 	CelebrityExchange.address,
	// 	100 * (10 ^ 18),
	// 	{ from: accounts[2] }
	// );
	// await WETHToken(wethAddress).approve(FANTokenICO.address, 100 * (10 ^ 18), {
	// 	from: accounts[0],
	// });
	// await WETHToken(wethAddress).approve(FANTokenICO.address, 100 * (10 ^ 18), {
	// 	from: accounts[1],
	// });
	// await WETHToken(wethAddress).approve(FANTokenICO.address, 100 * (10 ^ 18), {
	// 	from: accounts[2],
	// });
};
// ERC721 token contract does not need any other contract address
// fan token needs FANCExchangeAddress and celebrityexchange - make both 0x00
// fantokenico needs fan token
// Oracle needs FANCTokenAddress, FANCICOAddress, FANCExchangeAddress - exchange address will be 0x00 for now
// celebrity exchange needs FANC Token, oracle address and CelebrityOwnerTokenAddress
// generator needs erc721contract and celebrityexchange address

// add celebrity exchange address to fan token after all deployments

// erc20 needs celebrityexchange - will be auto generated from generator

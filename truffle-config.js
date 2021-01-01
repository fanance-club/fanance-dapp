const path = require("path");
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
	// See <http://truffleframework.com/docs/advanced/configuration>
	// to customize your Truffle configuration!
	contracts_build_directory: path.join(__dirname, "app/frontend/src/contracts"),
	networks: {
		develop: {
			// default with truffle unbox is 7545, but we can use develop to test changes, ex. truffle migrate --network develop
			host: "127.0.0.1",
			port: 7545,
			network_id: "*",
		},
		rinkeby: {
			provider: () =>
				new HDWalletProvider(
					"track urban song body clarify alarm firm bike guard agent small around",
					`https://rinkeby.infura.io/v3/76572308a2714058a90cddf49b651930`
				),
			network_id: 4, // Ropsten's id
			// gas: 10000000, // Ropsten has a lower block limit than mainnet
			// confirmations: 2,    // # of confs to wait between deployments. (default: 0)
			// timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
			skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
		},
		matic: {
			provider: () =>
				new HDWalletProvider(
					"track urban song body clarify alarm firm bike guard agent small around",
					`https://rpc-mumbai.maticvigil.com/v1/26861bde6490981e0002f737ca825005b583645a`
				),
			network_id: 80001,
			confirmations: 2,
			timeoutBlocks: 200,
			skipDryRun: true,
		},
		matic_mainnet: {
			provider: () =>
				new HDWalletProvider(
					"track urban song body clarify alarm firm bike guard agent small around",
					`https://rpc-mainnet.maticvigil.com/v1/26861bde6490981e0002f737ca825005b583645a`
				),
			network_id: 80001,
			confirmations: 2,
			timeoutBlocks: 200,
			skipDryRun: true,
		},
	},
	// Configure your compilers
	compilers: {
		solc: {
			version: "0.5.16", // Fetch exact version from solc-bin (default: truffle's version)
			// docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
			settings: {
				// See the solidity docs for advice about optimization and evmVersion
				optimizer: {
					enabled: true,
					runs: 200,
				},
				//  evmVersion: "byzantium"
			},
		},
	},
};

import TokenGenerator from "./contracts/TokenGenerator.json";
import CelebrityExchange from "./contracts/CelebrityExchange.json";
import CelebrityOwnerToken from "./contracts/CelebrityOwnerToken.json";
import FANCToken from "./contracts/FANCToken.json";
import FANCTokenICO from "./contracts/FANCTokenICO.json";
import Oracle from "./contracts/Oracle.json";

const options = {
	web3: {
		block: false,
		fallback: {
			type: "ws",
			url: "ws://127.0.0.1:7545",
		},
	},
	contracts: [
		TokenGenerator,
		CelebrityExchange,
		CelebrityOwnerToken,
		FANCToken,
		FANCTokenICO,
		Oracle,
	],
	events: {
		CelebrityExchange: [
			"BuyOrderCancelled",
			"BuyOrderFilled",
			"BuyOrderPartiallyFilled",
			"BuyOrderPlaced",
			"SellOrderCancelled",
			"SellOrderFilled",
			"SellOrderPartiallyFilled",
			"SellOrderPlaced",
			"InitialSellOrderPlaced",
			"OwnershipTransferred",
		],
		TokenGenerator: [
			"celebrityTokenRequestGenerated",
			"celebrityTokenRequestApproved",
			"celebrityTokenRequestRejected",
			"celebrityTokenGenerated",
		],
		FANCTokenICO: ["InvestmentReceived", "ICORoundStarted", "ICORoundEnded"],
		Oracle: ["FANCTokenAddressSet"],
	},
	polls: {
		// set polling interval to 30secs so we don't get buried in poll events
		// accounts: 30000,
	},
};

export default options;

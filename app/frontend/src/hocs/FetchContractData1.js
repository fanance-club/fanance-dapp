import React, { useState, useEffect } from "react";
import FetchContractData2 from "./FetchContractData2";
import tokenContract from "../contracts/CelebrityToken.json";

export default function FetchContractData1(props) {
	const [buyOrders, setBuyOrders] = useState([{ id: 0 }]);
	const [buyOrderCountValue, setBuyOrderCountValue] = useState(0);
	const [sellOrders, setSellOrders] = useState([{ id: 0 }]);
	const [sellOrderCountValue, setSellOrderCountValue] = useState(0);
	const [tokensList, setTokensList] = useState([{}]);
	useEffect(() => {
		let buyCount =
			props.drizzleState.contracts.CelebrityExchange.buyOrderCount[
				props.buyOrderCount
			];
		let tempBuyOrders = [];
		for (let i = 0; i < (buyCount && buyCount.value); i++) {
			let buyOrder = props.drizzle.contracts.CelebrityExchange.methods[
				"buyOrders"
			].cacheCall(i);
			tempBuyOrders.push(buyOrder);
		}
		setBuyOrders(tempBuyOrders);
		setBuyOrderCountValue(buyCount && buyCount.value);
		let sellCount =
			props.drizzleState.contracts.CelebrityExchange.sellOrderCount[
				props.sellOrderCount
			];
		let tempSellOrders = [];
		for (let i = 0; i < (sellCount && sellCount.value); i++) {
			let sellOrder = props.drizzle.contracts.CelebrityExchange.methods[
				"sellOrders"
			].cacheCall(i);
			tempSellOrders.push(sellOrder);
		}
		setSellOrders(tempSellOrders);
		setSellOrderCountValue(sellCount && sellCount.value);
		// get All Celebrities
		async function getAllCelebrities() {
			let tempTokensList = [];
			const web3 = props.drizzle.web3;
			let tokenCount =
				props.drizzleState.contracts.TokenGenerator.getAllCelebrities[
					props.tokensList
				];
			for (let i = 1; i < (tokenCount && tokenCount.value.length); i++) {
				// starts from 1 index in contract
				let tempTokenContract = new web3.eth.Contract(
					tokenContract.abi,
					tokenCount && tokenCount.value[i]
				);
				let symbol = await tempTokenContract.methods.symbol().call();
				let vertical = await tempTokenContract.methods.vertical().call();
				let id = await tempTokenContract.methods.id().call();
				let name = await tempTokenContract.methods.name().call();
				let category = await tempTokenContract.methods.category().call();

				tempTokensList.push({
					address: tokenCount && tokenCount.value[i],
					id: id,
					symbol: symbol,
					name: name,
					vertical: vertical,
					category: category,
				});
			}
			setTokensList(tempTokensList);
			props.handleTokensList(tempTokensList);
		}
		getAllCelebrities();
	}, [
		props.drizzleState.contracts.CelebrityExchange.buyOrderCount,
		props.drizzle.contracts.CelebrityExchange,
		props.buyOrderCount,
		props.drizzleState.contracts.CelebrityExchange.sellOrderCount,
		props.sellOrderCount,
		props.tokensList,
		props.drizzleState.contracts.TokenGenerator,
	]);
	return (
		<React.Fragment>
			<FetchContractData2
				drizzle={props.drizzle}
				drizzleState={props.drizzleState}
				buyOrders={buyOrders}
				buyCount={buyOrderCountValue}
				handleBuyOrders={props.handleBuyOrders}
				sellOrders={sellOrders}
				sellCount={sellOrderCountValue}
				handleSellOrders={props.handleSellOrders}
			/>
		</React.Fragment>
	);
}

import React, { useState, useEffect } from "react";
import FetchContractData1 from "./FetchContractData1";

export default function FetchContractData(props) {
	const [buyOrderCount, setBuyOrderCount] = useState(0);
	const [sellOrderCount, setSellOrderCount] = useState(0);
	// To provide as dependency for useEffect
	const events = props.drizzleState.contracts["CelebrityExchange"].events;
	const [completedTrades, setCompletedTrades] = useState([]);
	useEffect(
		() => {
			const tempBuyOrderCount = props.drizzle.contracts.CelebrityExchange.methods[
				"buyOrderCount"
			].cacheCall();
			setBuyOrderCount(tempBuyOrderCount);
			const tempSellOrderCount = props.drizzle.contracts.CelebrityExchange.methods[
				"sellOrderCount"
			].cacheCall();
			setSellOrderCount(tempSellOrderCount);

			// Fetch trades from events
			async function getTrades() {
				const web3 = props.drizzle.web3;
				const contract = props.drizzle.contracts["CelebrityExchange"];
				const yourContractWeb3 = new web3.eth.Contract(
					contract.abi,
					contract.address
				);
				let completedBuyOrders = [];
				let completedPartialBuyOrders = [];
				let completedSellOrders = [];
				let completedPartialSellOrders = [];
				let PartialBuyOrders = await yourContractWeb3.getPastEvents(
					"BuyOrderPartiallyFilled",
					{
						fromBlock: 0,
						toBlock: "latest",
					}
				);
				PartialBuyOrders.map((event) => {
					completedPartialBuyOrders.push(event.returnValues);
				});
				let FilledBuyOrders = await yourContractWeb3.getPastEvents(
					"BuyOrderFilled",
					{
						fromBlock: 0,
						toBlock: "latest",
					}
				);
				FilledBuyOrders.map((event) => {
					completedBuyOrders.push(event.returnValues);
				});
				let PartialSellOrders = await yourContractWeb3.getPastEvents(
					"SellOrderPartiallyFilled",
					{
						fromBlock: 0,
						toBlock: "latest",
					}
				);
				PartialSellOrders.map((event) => {
					completedPartialSellOrders.push(event.returnValues);
				});
				let FilledSellOrders = await yourContractWeb3.getPastEvents(
					"SellOrderFilled",
					{
						fromBlock: 0,
						toBlock: "latest",
					}
				);
				FilledSellOrders.map((event) => {
					completedSellOrders.push(event.returnValues);
				});

				setCompletedTrades(
					completedBuyOrders
						.concat(completedSellOrders)
						.concat(completedPartialSellOrders)
						.concat(completedPartialBuyOrders)
				);
				props.handleCompletedTrades(
					completedBuyOrders
						.concat(completedSellOrders)
						.concat(completedPartialSellOrders)
						.concat(completedPartialBuyOrders)
				);
			}
			getTrades();
			// eslint-disable-next-line react-hooks/exhaustive-deps
		},
		[props.drizzle.contracts.CelebrityExchange],
		events
	);

	return (
		<FetchContractData1
			drizzle={props.drizzle}
			drizzleState={props.drizzleState}
			buyOrderCount={buyOrderCount}
			handleBuyOrders={props.handleBuyOrders}
			sellOrderCount={sellOrderCount}
			handleSellOrders={props.handleSellOrders}
		/>
	);
}

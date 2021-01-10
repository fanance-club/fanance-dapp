import React, { useState, useEffect } from "react";
import moment from "moment";
import { Card } from "antd";

export default function Trades(props) {
	// To provide as dependency for useEffect
	const events = props.drizzleState.contracts["CelebrityExchange"].events;
	const [completedTrades, setCompletedTrades] = useState([]);

	useEffect(() => {
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
		}
		getTrades();
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [props.drizzle.contracts["CelebrityExchange"], events]);
	return (
		<div>
			<Card className="trades" style={{ overflow: "hidden" }}>
				<p
					style={{
						textAlign: "center",
						color: "white",
						fontSize: "14px",
					}}
				>
					Trades
				</p>
				<div style={{ height: "100%", overflow: "hidden" }}>
					<table style={{ width: "100%", textAlign: "center" }}>
						<thead>
							<tr>
								<th>Price</th>
								<th>Volume</th>
								<th>Time</th>
							</tr>
						</thead>
						<tbody>
							{typeof completedTrades != "undefined"
								? completedTrades
										.sort(
											(trade1, trade2) => trade2.timestamp - trade1.timestamp
										)
										.map((trade, index, array) => {
											let date =
												typeof trade != "undefined"
													? new Date(trade.timestamp * 1000)
													: null;
											return typeof trade != "undefined" ? (
												<tr key={index}>
													<td
														style={{
															color:
																typeof trade.price != "undefined" &&
																typeof array[index + 1] != "undefined" &&
																trade.price < array[index + 1].price
																	? "#f1432f"
																	: "#55bd6c",
														}}
													>
														{typeof trade.price != "undefined" &&
														typeof array[index + 1] != "undefined" &&
														trade.price < array[index + 1].price ? (
															<span>&darr;</span>
														) : (
															<span>&uarr;</span>
														)}
														{trade.price / 10 ** 18}
													</td>
													<td>{trade.numberOfTokens / 10 ** 18}</td>
													<td>{moment(date).fromNow()}</td>
												</tr>
											) : null;
										})
								: null}
						</tbody>
					</table>
				</div>
			</Card>
		</div>
	);
}

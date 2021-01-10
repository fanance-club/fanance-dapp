import React, { useState, useEffect } from "react";
import { Card, Row, Col } from "antd";
import BuyOrderBook from "./BuyOrderBook";
import SellOrderBook from "./SellOrderBook";

export default function Orderbook(props) {
	const [buyOrderCount, setBuyOrderCount] = useState(0);
	const [sellOrderCount, setSellOrderCount] = useState(0);
	useEffect(() => {
		const tempBuyOrderCount = props.drizzle.contracts.CelebrityExchange.methods[
			"buyOrderCount"
		].cacheCall();
		setBuyOrderCount(tempBuyOrderCount);
		const tempSellOrderCount = props.drizzle.contracts.CelebrityExchange.methods[
			"sellOrderCount"
		].cacheCall();
		setSellOrderCount(tempSellOrderCount);
	}, [props.drizzle.contracts.CelebrityExchange]);
	return (
		<React.Fragment>
			<Card className="orderBook" style={{ overflow: "hidden" }}>
				<Row>
					<Col span="12">
						<p
							style={{
								textAlign: "center",
								color: "white",
								fontSize: "14px",
							}}
						>
							Open Buy Orders
						</p>

						<table
							style={{
								width: "95%",
								textAlign: "right",
							}}
						>
							<thead>
								<tr>
									<th>Volume</th>
									<th>Buy Price</th>
								</tr>
							</thead>
						</table>
						<div style={{ height: "100%", overflow: "hidden" }}>
							<table
								style={{
									width: "95%",
									textAlign: "right",
								}}
							>
								<tbody>
									<BuyOrderBook
										drizzle={props.drizzle}
										drizzleState={props.drizzleState}
										buyOrderCount={buyOrderCount}
										handleBuyOrders={props.handleBuyOrders}
									/>
								</tbody>
							</table>
						</div>
					</Col>
					<Col span="12">
						<p
							style={{
								textAlign: "center",
								color: "white",
								fontSize: "14px",
							}}
						>
							Open Sell Orders
						</p>
						<div style={{ height: "100%", overflow: "hidden" }}>
							<table style={{ width: "95%" }}>
								<thead>
									<tr>
										<th>Sell Price</th>
										<th>Volume</th>
									</tr>
								</thead>
								<tbody>
									<SellOrderBook
										drizzle={props.drizzle}
										drizzleState={props.drizzleState}
										sellOrderCount={sellOrderCount}
										handleSellOrders={props.handleSellOrders}
									/>
								</tbody>
							</table>
						</div>
					</Col>
				</Row>
			</Card>
		</React.Fragment>
	);
}

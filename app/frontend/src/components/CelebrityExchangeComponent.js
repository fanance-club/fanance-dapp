import React from "react";
import PriceChart from "../containers/CelebrityExchange/PriceChart";
import AssetStats from "../containers/CelebrityExchange/AssetStats";
import TokensList from "../containers/CelebrityExchange/TokensList";
import PlaceOrders from "../containers/CelebrityExchange/PlaceOrders";
import OrderBook from "../containers/CelebrityExchange/OrderBook";
import Trades from "../containers/CelebrityExchange/Trades";
import CelebrityStats from "../containers/CelebrityExchange/CelebrityStats";
import MarketActivities from "../containers/CelebrityExchange/MarketActivities";
import UserOrders from "../containers/CelebrityExchange/UserOrders";

import "../CelebrityExchange.less";

import { Row, Col } from "antd";

const CelebrityExchangeComponent = () => {
	return (
		<React.Fragment>
			<Row>
				<Col span={6}>
					<TokensList />
				</Col>
				<Col span={12}>
					<Row>
						<Col span="24">
							<PriceChart />
						</Col>
						<Col span="24">
							<Row>
								<Col span="14">
									<OrderBook />
								</Col>
								<Col span="10">
									<Trades />
								</Col>
							</Row>
						</Col>
					</Row>
				</Col>
				<Col span={6}>
					<Row>
						<Col span="24">
							<PlaceOrders />
						</Col>

						<Col span="24">
							<UserOrders />
						</Col>
					</Row>
				</Col>
			</Row>
			<section></section>
			<section>
				<AssetStats />
			</section>
			<section></section>
			<section></section>
			<section></section>
			<section></section>
			<section>
				<CelebrityStats />
			</section>
			<section>
				<MarketActivities />
			</section>
			<section></section>
		</React.Fragment>
	);
};

export default CelebrityExchangeComponent;

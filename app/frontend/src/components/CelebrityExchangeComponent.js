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

class CelebrityExchangeComponent extends React.Component {
	render() {
		return (
			<React.Fragment>
				<Row>
					<Col span={6}>
						<TokensList />
					</Col>
					<Col span={12}>
						<Row>
							<Col span={24}>
								<PriceChart />
							</Col>
							<Col span={24}>
								<Row>
									<Col span={14}>
										<OrderBook
											drizzleState={this.props.drizzleState}
											buyOrders={this.props.buyOrders}
											sellOrders={this.props.sellOrders}
										/>
									</Col>
									<Col span={10}>
										<Trades
											drizzle={this.props.drizzle}
											drizzleState={this.props.drizzleState}
											completedTrades={this.props.completedTrades}
										/>
									</Col>
								</Row>
							</Col>
						</Row>
					</Col>
					<Col span={6}>
						<Row>
							<Col span={24}>
								<PlaceOrders
									drizzle={this.props.drizzle}
									drizzleState={this.props.drizzleState}
								/>
							</Col>

							<Col span={24}>
								<UserOrders
									buyOrders={this.props.buyOrders}
									sellOrders={this.props.sellOrders}
								/>
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
	}
}

export default CelebrityExchangeComponent;

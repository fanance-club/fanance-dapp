import React, { Component } from "react";
import "./App.less";
import Sample from "./Sample";
import CelebrityExchangeComponent from "./components/CelebrityExchangeComponent";
import HigherOrderComponent from "./hocs/Layout";

import { DrizzleContext } from "drizzle-react";

class App extends Component {
	render() {
		return (
			<React.Fragment>
				<section className="celebrityExchange">
					<CelebrityExchangeComponent
						drizzle={this.props.drizzle}
						drizzleState={this.props.drizzleState}
						buyOrders={this.props.buyOrders}
						sellOrders={this.props.sellOrders}
						completedTrades={this.props.completedTrades}
					/>
				</section>
			</React.Fragment>
		);
	}
}

App = HigherOrderComponent(App);
export default App;

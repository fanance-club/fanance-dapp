import React, { Component } from "react";
import "./App.less";
import Sample from "./Sample";
import CelebrityExchangeComponent from "./components/CelebrityExchangeComponent";
import HigherOrderComponent from "./hocs/Layout";

import { DrizzleContext } from "drizzle-react";

class App extends Component {
	render() {
		return (
			<DrizzleContext.Consumer>
				{(drizzleContext) => {
					const { drizzle, drizzleState, initialized } = drizzleContext;

					if (!initialized) {
						return "Loading...";
					}

					return (
						<React.Fragment>
							<section className="celebrityExchange">
								<CelebrityExchangeComponent
									drizzle={drizzle}
									drizzleState={drizzleState}
								/>
							</section>
							<Sample drizzle={drizzle} drizzleState={drizzleState} />
						</React.Fragment>
					);
				}}
			</DrizzleContext.Consumer>
		);
	}
}
App = HigherOrderComponent(App);
export default App;

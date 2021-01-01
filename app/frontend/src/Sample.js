import React, { Component } from "react";

class Sample extends Component {
	state = { counter: null };

	componentDidMount() {
		const { drizzle } = this.props;
		const contract = drizzle.contracts.TokenGenerator;

		// let drizzle know we want to watch the `myString` method
		const counter = contract.methods["counter"].cacheCall();

		// save the `dataKey` to local component state for later reference
		this.setState({ counter });
	}

	render() {
		// get the contract state from drizzleState
		const { TokenGenerator } = this.props.drizzleState.contracts;

		// using the saved `dataKey`, get the variable we're interested in
		const myString = TokenGenerator.counter[this.state.counter];

		// if it exists, then we display its value
		return <p>My stored string: {myString && myString.value}</p>;
	}
}

export default Sample;

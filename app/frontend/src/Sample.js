import React from "react";

class Sample extends React.Component {
	state = { dataKey: null };

	componentDidMount() {
		const { drizzle } = this.props;
		const contract = drizzle.contracts.TokenGenerator;

		// get and save the key for the variable we are interested in
		const dataKey = contract.methods["owner"].cacheCall();
		this.setState({ dataKey });
	}

	render() {
		const { TokenGenerator } = this.props.drizzleState.contracts;
		const storedData = TokenGenerator.owner[this.state.dataKey];
		return (
			<React.Fragment>
				<div>Stored Data: {storedData && storedData.value}</div>
			</React.Fragment>
		);
	}
}

export default Sample;

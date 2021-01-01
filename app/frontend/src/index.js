import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import reportWebVitals from "./reportWebVitals";
// import drizzle functions and contract artifact
import { Drizzle } from "@drizzle/store";
import TokenGenerator from "./contracts/TokenGenerator.json";

// let drizzle know what contracts we want and how to access our test blockchain
const options = {
	contracts: [TokenGenerator],
	web3: {
		fallback: {
			type: "http",
			url: "http://127.0.0.1:7545",
		},
	},
};

// setup drizzle
const drizzle = new Drizzle(options);

ReactDOM.render(
	<React.StrictMode>
		<App drizzle={drizzle} />
	</React.StrictMode>,
	document.getElementById("root")
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();

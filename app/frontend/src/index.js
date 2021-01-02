import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import reportWebVitals from "./reportWebVitals";

// 1. Import drizzle, drizzle-react, and your contract artifacts.
import { Drizzle, generateStore } from "@drizzle/store";
import { DrizzleContext } from "drizzle-react";
import drizzleOptions from "./drizzleOptions";
const initialState = { nothing: false };
// 2. Setup the drizzle instance.
const drizzleStore = generateStore(drizzleOptions, initialState);
const drizzle = new Drizzle(drizzleOptions, drizzleStore);

ReactDOM.render(
	<DrizzleContext.Provider drizzle={drizzle}>
		<App />
	</DrizzleContext.Provider>,
	document.getElementById("root")
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();

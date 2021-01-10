const CracoLessPlugin = require("craco-less");

module.exports = {
	plugins: [
		{
			plugin: CracoLessPlugin,
			options: {
				lessLoaderOptions: {
					lessOptions: {
						modifyVars: {
							"@primary-color": "#18FFFF",
							"@text-color": "black",
							"@btn-primary-color": "black",
							"@layout-header-height": "50px",
							"@label-color": "white",
							"@input-color": "white",
							"@input-bg": "#424242",
							"@input-border-color": "gray",
							"@input-icon-color": "white",
							"@input-addon-bg": "#212121",
							"@progress-text-color": "white",
						},
						javascriptEnabled: true,
					},
				},
			},
		},
	],
};

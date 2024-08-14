import (
	"vela/kube"
	"vela/utils"
	"encoding/base64"
)

"generate-jdbc-connection": {
	type: "workflow-step"
	annotations: {
		"category": "Terraform"
	}
	description: "Generate a JDBC connection based on Component of alibaba-rds"
}
template: {
	output: kube.#Read & {
		$params: {
			value: {
				apiVersion: "v1"
				kind:       "Secret"
				metadata: {
					name: parameter.name
					if parameter.namespace != _|_ {
						namespace: parameter.namespace
					}
				}
			}
		}
	}
	dbHost:   utils.#ConvertString & {$params: bt: base64.Decode(null, output.$returns.value.data["DB_HOST"])}
	dbPort:   utils.#ConvertString & {$params: bt: base64.Decode(null, output.$returns.value.data["DB_PORT"])}
	dbName:   utils.#ConvertString & {$params: bt: base64.Decode(null, output.$returns.value.data["DB_NAME"])}
	username: utils.#ConvertString & {$params: bt: base64.Decode(null, output.$returns.value.data["DB_USER"])}
	password: utils.#ConvertString & {$params: bt: base64.Decode(null, output.$returns.value.data["DB_PASSWORD"])}

	env: [
		{name: "url", value:      "jdbc://" + dbHost.$returns.str + ":" + dbPort.$returns.str + "/" + dbName.$returns.str + "?characterEncoding=utf8&useSSL=false"},
		{name: "username", value: username.$returns.str},
		{name: "password", value: password.$returns.str},
	]

	parameter: {
		// +usage=Specify the name of the secret generated by database component
		name: string
		// +usage=Specify the namespace of the secret generated by database component
		namespace?: string
	}
}

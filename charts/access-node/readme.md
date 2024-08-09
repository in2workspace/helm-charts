The access node has a set of environment variables and parameters that the user must configure. Below is a list of mandatory configuration variables.

| Key                             | Comment                                                             | Possible Values                                                             |
|---------------------------------|---------------------------------------------------------------------|-----------------------------------------------------------------------------|
| access-node.dlt-adapter.env.PRIVATE_KEY | Private key to sign transactions                                       | Example: 0x4c88c1c84e65e82b9ed6b49313c6a624d58b2b11e40b4b64e3b9d0a1d5e6dfad |
| access-node.dlt-adapter.env.RPC_ADDRESS | Node address, typically a URL that points to a blockchain node           | Example: https://red-t.alastria.io/v0/id                                    |
| access-node.dlt-adapter.env.ISS  | Organization identifier hashed with SHA-256, derived from the `organizationIdentifier` below | Example: 0x43b27fef24cfe8a0b797ed8a36de2884f9963c0c2a0da640e3ec7ad6cd0c493d |
| access-node.desmos.app.operator.organizationIdentifier | DID of the operator, should follow the format `did:elsi`              | Example: did:elsi:VATFR-696240139                                           |


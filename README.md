# swift-hsdp-sdk

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This SDK provides a simple interface to features offered by the IAM services of HSDP.

The output of the project is a libary that you can import as a package in your xcode environment.

## Table of contents

- [Using in your projects](#using-in-your-projects)
- [Basic usage](#basic-usage)
- [Supported APIs](#supported-apis)
- [Todo](#todo)
- [Issues](#issues)
- [Contact / Getting help](#contact--geting-help)
- [License](#license)


## Using in your projects

The library dependency can be included in your projects by adding https://github.com/philips-software/swift-hsdp-sdk as package collection.

## Basic Usage

```
import SwiftHsdpSdk

let hsdpSkd = SwiftHsdpSdk();

// Login Request
Task {
    let request = LoginRequest(username: "user@mail.com", password: "p@ssw0rd", 
    basicAuthentication: BasicAuthentication(username: "public-client", password: ""));

    let value = try await hsdpSkd.login(lr: request);
    let accessToken = value.access_token
    let refreshToken = value.refresh_token

}

// Introspect
Task {
    let request = IntrospectRequest(accessToken: accessToken, basicAuthentication: BasicAuthentication(username: "username",
    password: "p@ssw0rd"));

    let value = try await hsdpSkd.introspect(ir: request);
    let isTokenActive = String(value.active)
}

// Refresh Token

Task {
    let request = RefreshRequest(refreshToken: refreshToken, basicAuthentication: BasicAuthentication(username: "username",
    password: ""));

    let value = try await hsdpSkd.refresh(rr: request);
    let accessToken = value.access_token
}

// Revoke Token

Task {
    let request = RevokeRequest(token: accessToken, basicAuthentication: BasicAuthentication(username: "username", 
    password: "p@ssw0rd"));

    hsdpSkd.revoke(rr: request) {result in
        ""
    };
}



```

## Supported APIs

The current implementation covers only a subset of HSDP APIs. Additional functionality is built as needed.

- [x] IAM Identity and Access Management (IAM)
  - [ ] Access Management
    - [ ] Federation
    - [x] OAuth2
      - [x] OAuth2 Authorization
      - [x] OAuth2 Token Revocation
      - [ ] OpenID Connect UserInfo
      - [x] Introspect
      - [x] Session (refresh, terminate)
      - [ ] OpenID (configuration, JWKS)


Other services can follow later.


## Todo

- Implement more HSDP API calls


## Issues

- If you have an issue: report it on the [issue tracker](https://github.com/philips-software/swift-hsdp-sdk/issues)


## Contact / Getting help

Matthijs van Marion (<matthijs.van.marion@philips.com>) \
Martijn van Welie (<martijn.van.welie@philips.com>)

## License

See [LICENSE.md](LICENSE.md).
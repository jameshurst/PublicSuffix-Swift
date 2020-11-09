# PublicSuffix

A Swift package that uses the [Public Suffix List](https://publicsuffix.org) to parse domain names.

## Usage

 ```swift
 let components = SuffixList.default.parse("www.example.com")
 print(components?.tld) // com
 print(components?.sld) // example
 print(domainName?.domain) // example.com
 print(domainName?.subdomain) // www
 ```

## SuffixList

A `SuffixList` is used to parse domain names.

A bundled version of the public suffix list is included as `SuffixList.default`. You may also use your own custom suffix list.

## Installation

### Xcode 11+

* Select **File** > **Swift Packages** > **Add Package Dependency...**
* Enter the package repository URL: `https://github.com/jameshurst/PublicSuffix-Swift.git`
* Confirm the version and let Xcode resolve the package

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

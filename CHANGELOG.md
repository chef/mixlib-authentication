# mixlib-authentication Changelog

<!-- latest_release unreleased -->
## Unreleased

#### Merged Pull Requests
- bump version to 2.1.0 [#38](https://github.com/chef/mixlib-authentication/pull/38) ([thommay](https://github.com/thommay))
<!-- latest_release -->

<!-- release_rollup since=2.0.0 -->
### Changes since 2.0.0 release

#### Merged Pull Requests
- bump version to 2.1.0 [#38](https://github.com/chef/mixlib-authentication/pull/38) ([thommay](https://github.com/thommay)) <!-- 2.1.0 -->
- Forgot to put sign_version in the opts which would make it nil when p… [#37](https://github.com/chef/mixlib-authentication/pull/37) ([coderanger](https://github.com/coderanger)) <!-- 2.0.2 -->
-  Support signing with ssh-agent (round two) [#36](https://github.com/chef/mixlib-authentication/pull/36) ([coderanger](https://github.com/coderanger)) <!-- 2.0.1 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v2.0.0](https://github.com/chef/mixlib-authentication/tree/v2.0.0) (2018-04-12)

#### Merged Pull Requests
- Move mixlib-auth debugging to trace level [#32](https://github.com/chef/mixlib-authentication/pull/32) ([thommay](https://github.com/thommay))
<!-- latest_stable_release -->

## 1.4.2 (2017-08-17)

- fix bug in ordering x_ops_authorization_n headers when headers
  number more than 9 [dde604f] [#5]
- fix bug where a constant lookup fails when vendored into other
  projects [#24]
- make mixlib-log optional [#21]

## 1.4.1 (2016-06-08)

- testing and style modernization [#13, #14, #15, #18]

## 1.4.0 (2015-01-19)

- Add Chef signing protocol version 1.3
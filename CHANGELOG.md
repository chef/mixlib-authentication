# mixlib-authentication Changelog

<!-- latest_release unreleased -->
## Unreleased

#### Merged Pull Requests
- update travis, drop ruby &lt; 2.5, major version bump [#45](https://github.com/chef/mixlib-authentication/pull/45) ([lamont-granquist](https://github.com/lamont-granquist))
<!-- latest_release -->

<!-- release_rollup since=2.1.1 -->
### Changes since 2.1.1 release

#### Merged Pull Requests
- update travis, drop ruby &lt; 2.5, major version bump [#45](https://github.com/chef/mixlib-authentication/pull/45) ([lamont-granquist](https://github.com/lamont-granquist)) <!-- 3.0.0 -->
- Only ship the required libraries in the gem artifact [#44](https://github.com/chef/mixlib-authentication/pull/44) ([tas50](https://github.com/tas50)) <!-- 2.1.5 -->
- Update codeowners and add github PR template [#43](https://github.com/chef/mixlib-authentication/pull/43) ([tas50](https://github.com/tas50)) <!-- 2.1.4 -->
- Update testing boilerplate [#41](https://github.com/chef/mixlib-authentication/pull/41) ([tas50](https://github.com/tas50)) <!-- 2.1.3 -->
- remove hashrocket syntax [#40](https://github.com/chef/mixlib-authentication/pull/40) ([lamont-granquist](https://github.com/lamont-granquist)) <!-- 2.1.2 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v2.1.1](https://github.com/chef/mixlib-authentication/tree/v2.1.1) (2018-06-08)

#### Merged Pull Requests
- Silence the warning for the default positional args case [#39](https://github.com/chef/mixlib-authentication/pull/39) ([coderanger](https://github.com/coderanger))
<!-- latest_stable_release -->

## [v2.1.0](https://github.com/chef/mixlib-authentication/tree/v2.1.0) (2018-05-31)

#### Merged Pull Requests
-  Support signing with ssh-agent (round two) [#36](https://github.com/chef/mixlib-authentication/pull/36) ([coderanger](https://github.com/coderanger))
- Forgot to put sign_version in the opts which would make it nil when p… [#37](https://github.com/chef/mixlib-authentication/pull/37) ([coderanger](https://github.com/coderanger))
- bump version to 2.1.0 [#38](https://github.com/chef/mixlib-authentication/pull/38) ([thommay](https://github.com/thommay))

## [v2.0.0](https://github.com/chef/mixlib-authentication/tree/v2.0.0) (2018-04-12)

#### Merged Pull Requests
- Move mixlib-auth debugging to trace level [#32](https://github.com/chef/mixlib-authentication/pull/32) ([thommay](https://github.com/thommay))

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
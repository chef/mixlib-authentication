# mixlib-authentication Changelog

<!-- latest_release 3.1.1 -->
## [v3.1.1](https://github.com/chef/mixlib-authentication/tree/v3.1.1) (2024-12-17)

#### Merged Pull Requests
- [CI] Drop EOL Rubies [#60](https://github.com/chef/mixlib-authentication/pull/60) ([dafyddcrosby](https://github.com/dafyddcrosby))
<!-- latest_release -->

<!-- release_rollup since=3.0.10 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- [CI] Drop EOL Rubies [#60](https://github.com/chef/mixlib-authentication/pull/60) ([dafyddcrosby](https://github.com/dafyddcrosby)) <!-- 3.1.1 -->
- Remove Ruby 2.4 support &amp; Test Ruby 3.1 [#59](https://github.com/chef/mixlib-authentication/pull/59) ([poorndm](https://github.com/poorndm)) <!-- 3.1.0 -->
- Upgrade to GitHub-native Dependabot [#57](https://github.com/chef/mixlib-authentication/pull/57) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot])) <!-- 3.0.11 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v3.0.10](https://github.com/chef/mixlib-authentication/tree/v3.0.10) (2021-03-15)

#### Merged Pull Requests
- Split using a string not a regex [#55](https://github.com/chef/mixlib-authentication/pull/55) ([tas50](https://github.com/tas50))
- Replace __FILE__ with __dir__ and use safe operators [#54](https://github.com/chef/mixlib-authentication/pull/54) ([tas50](https://github.com/tas50))
- Test on Ruby 3 and update gem caching [#56](https://github.com/chef/mixlib-authentication/pull/56) ([tas50](https://github.com/tas50))
<!-- latest_stable_release -->

## [v3.0.7](https://github.com/chef/mixlib-authentication/tree/v3.0.7) (2020-08-21)

#### Merged Pull Requests
- Optimize our requires [#53](https://github.com/chef/mixlib-authentication/pull/53) ([tas50](https://github.com/tas50))

## [v3.0.6](https://github.com/chef/mixlib-authentication/tree/v3.0.6) (2019-12-30)

#### Merged Pull Requests
- Test on Ruby 2.7 + random testing improvements [#51](https://github.com/chef/mixlib-authentication/pull/51) ([tas50](https://github.com/tas50))
- Substitute require for require_relative [#52](https://github.com/chef/mixlib-authentication/pull/52) ([tas50](https://github.com/tas50))

## [v3.0.4](https://github.com/chef/mixlib-authentication/tree/v3.0.4) (2019-10-31)

#### Merged Pull Requests
- Add BuildKite PR Testing [#47](https://github.com/chef/mixlib-authentication/pull/47) ([tas50](https://github.com/tas50))
- Update project owner + Remove Travis CI [#48](https://github.com/chef/mixlib-authentication/pull/48) ([tas50](https://github.com/tas50))
- Update mixlib-log requirement from ~&gt; 2 to ~&gt; 3 [#50](https://github.com/chef/mixlib-authentication/pull/50) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))

## [v3.0.1](https://github.com/chef/mixlib-authentication/tree/v3.0.1) (2019-04-23)

#### Merged Pull Requests
- remove hashrocket syntax [#40](https://github.com/chef/mixlib-authentication/pull/40) ([lamont-granquist](https://github.com/lamont-granquist))
- Update testing boilerplate [#41](https://github.com/chef/mixlib-authentication/pull/41) ([tas50](https://github.com/tas50))
- Update codeowners and add github PR template [#43](https://github.com/chef/mixlib-authentication/pull/43) ([tas50](https://github.com/tas50))
- Only ship the required libraries in the gem artifact [#44](https://github.com/chef/mixlib-authentication/pull/44) ([tas50](https://github.com/tas50))
- update travis, drop ruby &lt; 2.5, major version bump [#45](https://github.com/chef/mixlib-authentication/pull/45) ([lamont-granquist](https://github.com/lamont-granquist))
- Add back Ruby 2.4 support / update testing [#46](https://github.com/chef/mixlib-authentication/pull/46) ([tas50](https://github.com/tas50))

## [v2.1.1](https://github.com/chef/mixlib-authentication/tree/v2.1.1) (2018-06-08)

#### Merged Pull Requests
- Silence the warning for the default positional args case [#39](https://github.com/chef/mixlib-authentication/pull/39) ([coderanger](https://github.com/coderanger))

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
#
# Copyright:: Copyright (c) 2018 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "mixlib/authentication/digester"

describe Mixlib::Authentication::Digester do
  context "backcompat" do
    # The digester API should really have been private,
    # however oc-chef-pedant uses it.
    let(:test_string) { "hello" }
    let(:test_string_checksum) { "qvTGHdzF6KLavt4PO0gs2a6pQ00=" }

    describe "#hash_file" do
      it "should default to use SHA1" do
        expect(described_class.hash_file(StringIO.new(test_string))).to(
          eq(test_string_checksum)
        )
      end
    end

    describe "#hash_string" do
      it "should default to use SHA1" do
        expect(described_class.hash_string(test_string)).to(
          eq(test_string_checksum)
        )
      end
    end
  end
end

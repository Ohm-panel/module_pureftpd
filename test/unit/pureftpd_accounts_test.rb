### Ohm PureFTPd module <http://joelcogen.com/projects/ohm/> ###
#
# Accounts test
#
# Copyright (C) 2010 Joel Cogen <http://joelcogen.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this module. If not, see <http://www.gnu.org/licenses/>.
#
# This program incorporates work covered by the following copyright and
# permission notice:
#
#   Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#
#   - Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   - Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#   - Neither the name of UMONS nor the names of its contributors may be used
#     to endorse or promote products derived from this software without specific
#     prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#   POSSIBILITY OF SUCH DAMAGE.

require 'test_helper'

class PureftpdAccountsTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert pureftpd_accounts(:one).valid?, "fixtures: one is invalid"
    assert pureftpd_accounts(:two).valid?, "fixtures: two is invalid"
  end

  test "invalid without username, password or domain" do
    acc = PureftpdAccount.new
    acc.save
    assert acc.errors.invalid?(:username), "Blank username accepted"
    assert acc.errors.invalid?(:password), "Blank password accepted"
    assert acc.errors.invalid?(:domain_id), "Blank domain accepted"
  end

  test "password change" do
    acc = pureftpd_accounts(:one)
    acc.password = "new password"
    acc.password_confirmation = acc.password
    assert acc.valid?, "Good new password rejected"

    acc.password_confirmation = "something else"
    acc.save
    assert acc.errors.invalid?(:password_confirmation), "Incorrect password confirmation accepted"
  end

  test "username format" do
    acc = pureftpd_accounts(:one)
    acc.username = "valid_username-ok"
    assert acc.valid?, "Good username rejected"

    acc.username = "000invalid_username"
    acc.save
    assert acc.errors.invalid?(:username), "Bad username accepted"

    acc.username = "invalid username"
    acc.save
    assert acc.errors.invalid?(:username), "Bad username accepted"

    acc.username = "invalid/username"
    acc.save
    assert acc.errors.invalid?(:username), "Bad username accepted"
  end

  test "username unique" do
    acc = PureftpdAccount.new(:username  => pureftpd_accounts(:one).username,
                              :password  => "some password",
                              :domain_id => pureftpd_accounts(:one).domain_id)
    acc.save
    assert acc.errors.invalid?(:username), "Duplicate username accepted"
  end

  test "illegal domain" do
    acc = pureftpd_accounts(:one)
    acc.domain_id = 2
    acc.save
    assert acc.errors.invalid?(:domain), "Illegal domain accepted"
  end

  test "root" do
    # Valid root dir
    acc = pureftpd_accounts(:one)
    acc.root = "/test.dir/test_dir/test-dir/test dir"
    assert acc.valid?, "Good root rejected"

    # Invalid root dir (.. refused)
    acc.root = "../imdahacker/"
    acc.save
    assert acc.errors.invalid?(:root), "Root with .. accepted"
  end
end


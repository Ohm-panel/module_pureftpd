### Ohm PureFTPd module <http://joelcogen.com/projects/ohm/> ###
#
# Accounts controller test
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

class PureftpdAccountsControllerTest < ActionController::TestCase
  test "should get login" do
    get :index
    assert_redirected_to :controller => 'login', :action => 'index'
  end

  test "should get index" do
    login_as users(:one)
    get :index
    assert_response :success
  end

  test "should get new" do
    login_as users(:one)
    get :new
    assert_response :success
  end

  test "should create account" do
    login_as users(:root)
    assert_difference('PureftpdAccount.count') do
      post :create, :pureftpd_account => { :username => "newtest", :root => "", :password => "newpass", :password_confirmation => "newpass", :domain_id => 1 }
    end
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to create account" do
    login_as users(:two)
    assert_difference('PureftpdAccount.count', 0) do
      post :create, :pureftpd_account => { :username => "newtest", :root => "", :password => "newpass", :password_confirmation => "newpass", :domain_id => 1 }
    end
    assert_redirected_to :controller => 'dashboard', :action => 'index'
  end

  test "should get edit" do
    login_as users(:root)
    get :edit, :id => pureftpd_accounts(:one).to_param
    assert_response :success
  end

  test "should refuse to edit" do
    login_as users(:one)
    get :edit, :id => pureftpd_accounts(:one).to_param
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error]
  end

  test "should update account" do
    login_as users(:root)
    put :update, :id => pureftpd_accounts(:one).to_param, :pureftpd_account => { }
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to update account" do
    login_as users(:one)
    put :update, :id => pureftpd_accounts(:one).to_param, :pureftpd_account => { }
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error]
  end

  test "should destroy account" do
    login_as users(:root)
    assert_difference('PureftpdAccount.count', -1) do
      delete :destroy, :id => pureftpd_accounts(:one).to_param
    end
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to destroy account" do
    login_as users(:one)
    assert_difference('PureftpdAccount.count', 0) do
      delete :destroy, :id => pureftpd_accounts(:one).to_param
    end
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error]
  end
end


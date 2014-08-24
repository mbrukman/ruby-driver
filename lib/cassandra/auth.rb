# encoding: utf-8

# Copyright 2013-2014 DataStax, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Cassandra
  module Auth
    # An auth provider is a factory for {Cassandra::Auth::Authenticator} instances
    # (or objects matching that interface). Its {#create_authenticator} will be
    # called once for each connection that requires authentication.
    #
    # If the authentication requires keeping state, keep that in the
    # authenticator instances, not in the auth provider.
    #
    # @note Creating an authenticator must absolutely not block, or the whole
    #   connection process will block.
    #
    # @abstract Auth providers given to {Cassandra::Builder#with_auth_provider} don't
    #   need to be subclasses of this class, but need to implement the same
    #   methods. This class exists only for documentation purposes.
    #
    # @see Cassandra::Auth::Providers
    class Provider
      # @!method create_authenticator(authentication_class, protocol_version)
      #
      # Create a new authenticator object. This method will be called once per
      # connection that requires authentication. The auth provider can create
      # different authenticators for different authentication classes, or return
      # nil if it does not support the authentication class.
      #
      # @note This method must absolutely not block.
      #
      # @param authentication_class [String] the authentication class used by
      #   the server.
      # @return [Cassandra::Client::Authenticator, nil] an object with an interface
      #   matching {Cassandra::Client::Authenticator} or nil if the authentication
      #   class is not supported.
    end

    # An authenticator handles the authentication challenge/response cycles of
    # a single connection. It can be stateful, but it must not for any reason
    # block. If any of the method calls block, the whole connection process
    # will be blocked.
    #
    # @note Authenticators created by auth providers don't need to be subclasses
    #   of this class, but need to implement the same methods. This class exists
    #   only for documentation purposes.
    #
    # @see Cassandra::Auth::Provider
    class Authenticator
      # @!method initial_response
      #
      # This method must return the initial authentication token to be sent to
      # the server.
      #
      # @note This method must absolutely not block.
      #
      # @return [String] the initial authentication token

      # @!method challenge_response(token)
      #
      # If the authentication requires multiple challenge/response cycles this
      # method will be called when a challenge is returned by the server. A
      # response token must be created and will be sent back to the server.
      #
      # @note This method must absolutely not block.
      #
      # @param token [String] a challenge token sent by the server
      # @return [String] the authentication token to send back to the server

      # @!method authentication_successful(token)
      #
      # Called when the authentication is successful.
      #
      # @note This method must absolutely not block.
      #
      # @param token [String] a token sent by the server
      # @return [void]
    end
  end
end

require 'cassandra/auth/providers'
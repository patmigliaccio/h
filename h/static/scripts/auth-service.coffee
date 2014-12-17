###*
# @ngdoc service
# @name  Auth
#
# @description
# The 'Auth' service exposes the currently logged in user for other components,
# configures the Annotator.Auth plugin according to the login/logout events
# and provides a method for permitting a certain operation for a user with a
# given annotation
###
class Auth

  this.$inject = ['$location', '$rootScope',
                  'annotator', 'documentHelpers', 'identity']
  constructor:   ( $location,   $rootScope,
                   annotator,   documentHelpers,   identity) ->
    {plugins} = annotator
    _checkingToken = false
    @user = undefined

    # Fired when the identity-service successfully requests authentication.
    # Sets up the Annotator.Auth plugin instance and after the plugin
    # initialization it sets up an Annotator.Permissions plugin instance
    # and finally it sets the auth.user property. It sets a flag between
    # that time period to indicate that the token is being checked.
    onlogin = (assertion) =>
      _checkingToken = true

      # Configure the Auth plugin with the issued assertion as refresh token.
      annotator.addPlugin 'Auth',
        tokenUrl: documentHelpers.absoluteURI(
          "/api/token?assertion=#{assertion}")

      # Set the user from the token.
      plugins.Auth.withToken (token) =>
        _checkingToken = false
        # Annotator needs to access the user property without the permissions
        # plugin and since auth service depends on annotator, the annotator
        # service cannot use the auth service
        annotator.user = token.userId
        @user = token.userId
        $rootScope.$apply()

    # Fired when the identity-service forgets authentication.
    # Destroys the Annotator.Auth and Permissions plugin instances and sets
    # the user to null.
    onlogout = =>
      plugins.Auth?.element.removeData('annotator:headers')
      plugins.Auth?.destroy()
      delete plugins.Auth

      annotator.user = null
      @user = null
      _checkingToken = false

    # Fired after the identity-service requested authentication (both after
    # a failed or succeeded request). It detects if the first login request
    # has failed and if yes, it sets the user value to null. (Otherwise the
    # onlogin method would set it to userId)
    onready = =>
      if @user is undefined and not _checkingToken
        @user = null
        annotator.user = null

    identity.watch {onlogin, onlogout, onready}


angular.module('h')
.service('auth', Auth)

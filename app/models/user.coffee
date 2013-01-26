Spine = require('spine')

class User extends Spine.Model
  @configure 'User', 'ID', 'Forename', 'Surname', 'EmailAddress', 'Tag', 'FacebookID', 'ProfilePictureUrl', 'TotalRaised', 'TotalDonated', 'Events', 'Groups', 'Bio'
  @extend Spine.Model.Local
  validate: ->
    return 'Forename required' unless @Forename
    return 'Surname required' unless @Surname
    return 'Email required' unless @Email
    return 'Password required' unless @Password

module.exports = User

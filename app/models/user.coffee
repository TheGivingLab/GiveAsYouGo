Spine = require('spine')
Time = require('lib/time')

class User extends Spine.Model
  @configure 'User', 'ID', 'Forename', 'Surname', 'EmailAddress', 'MemberSince', 'Tag', 'FacebookID', 'ProfilePictureUrl', 'TotalRaised', 'TotalDonated', 'Events', 'Groups', 'Bio'
  @extend Spine.Model.Local
  Name: ->
    [@Forename, @Surname].join ' '
  MemberFor: ->
    if @MemberSince
      Time.hoursAgo Time.toDateFromAspNet @MemberSince
    else
      'unknown time ago'

  validate: ->
    return 'Forename required' unless @Forename
    return 'Surname required' unless @Surname
    return 'Email required' unless @EmailAddress

module.exports = User

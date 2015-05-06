{expect} = require 'chai'

{AppConfigActions, AppConfigStore} = require '../src/flux/app-config'

describe 'App Configuration', ->

  it 'calculates resource links', ->
    # Karma doesn't load the tutor.css so the default should be returned
    expect( AppConfigStore.getAssetsPrefix() ).to.eq "/"
    AppConfigActions.setAssetsPrefix("https://crazy-bobs-cheap-servers.testing/")
    expect( AppConfigStore.urlForResource("foo/an-image.png") )
      .to.equal("https://crazy-bobs-cheap-servers.testing/foo/an-image.png")

# #Plugin template

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the 
# basics of how the plugin system works and what a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take 
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  request = env.require 'request'

  # Include your own depencies with nodes global require function:
  #  
  #     someThing = require 'someThing'
  #  

  # ###MyPlugin class
  # Create a class that extends the Plugin class and implements the following functions:
  class Jointspace extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #  
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins` 
    #     section of the config.json file 
    #     
    # 
    init: (app, @framework, @config) =>
      env.logger.info("Hello World")

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("JointspacePowerButton", {
        configDef: deviceConfigDef.JointspacePowerButton, 
        createCallback: (config) => new JointspacePowerButton(config)
      })


  class JointspacePowerButton extends env.devices.ButtonsDevice
    constructor: (@config, @plugin) ->
      @name = @config.name
      @tvIP = @config.tvIP
      @buttons = @config.buttons

      env.logger.info("Button Device init")

      super(@config)

    destroy: () ->
      @requestPromise.cancel() if @requestPromise?
      super()

    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          env.logger.info("pressing a button!!!")
          json_params = {key: "Standby"}

          request.post {uri:"http://#{@tvIP}:1925/1/input/key", json : json_params}, (error, response, body) ->
            env.logger.debug(response)

          return Promise.resolve()
  

  # ###Finally
  # Create a instance of my plugin
  myPlugin = new Jointspace
  # and return it to the framework.
  return myPlugin

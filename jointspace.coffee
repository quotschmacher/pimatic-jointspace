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

  request = require 'request'

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
      env.logger.info @config.tvip

      @tvip = @config.tvip

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("JointspaceDirectInput", {
        configDef: deviceConfigDef.JointspaceDirectInput, 
        createCallback: (config) => new JointspaceDirectInput(config, @)
      })

      @framework.deviceManager.registerDeviceClass("JointspaceSourceSelection", {
        configDef: deviceConfigDef.JointspaceSourceSelection, 
        createCallback: (config) => new JointspaceSourceSelection(config, @)
      })

      @framework.deviceManager.on 'discover', () =>
        env.logger.debug("Starting discovery - debug")
        env.logger.info("Starting discovery - info")
        @framework.deviceManager.discoverMessage(
          'pimatic-jointspace', "Searching for devices"
        )

        #als erstes dann ein JointspacePowerButton device anbieten??
        devManager = @framework.deviceManager

        # Sources durchegehen
        request.get {uri:"http://#{@tvip}:1925/1/sources", json : true}, (error, response, body) ->
          if error isnt null
            env.logger.error("#{error.syscall} #{error.errno}")
          else
            deviceConfig = 
              class: "JointspaceSourceSelection"
              name: "Jointspace Source Selection"
              id: "jointspace-source-selection"

            env.logger.debug(body)
            buttonsArray = []
            for key, value of body
              env.logger.debug(value)
              button_command = key
              button_text = ""
              for k, v of value
                if k is "name"
                  button_text = v
              button_id = key
              button_config =
                id: button_id
                text: button_text
                command: button_command
              buttonsArray.push(button_config)
            deviceConfig.buttons = buttonsArray

            #notify about the discovered device
            #@framework.deviceManager.discoveredDevice(
            devManager.discoveredDevice(
              'pimatic-jointspace', "#{deviceConfig.name}", deviceConfig
            )

  class JointspaceDirectInput extends env.devices.ButtonsDevice
    constructor: (@config, @plugin) ->
      @name = @config.name
      @tvIP = @plugin.tvip
      @buttons = @config.buttons

      env.logger.info("Button Device init")
      env.logger.info("IP of #{@name} is #{@tvIP}")

      for b in @config.buttons
        if b.text is ""
          b.text = b.command
        if b.id is ""
          b.id = "jointspace_#{@tvIP.replace(/\./g, "-")}_#{b.command.toLowerCase()}"

      super(@config)

    destroy: () ->
      @requestPromise.cancel() if @requestPromise?
      super()

    buttonPressed: (buttonId) ->
      btn_id_found = false
      for b in @config.buttons
        if b.id is buttonId
          btn_id_found = true
          env.logger.info("pressing button #{b.command}")
          json_params = {key: b.command}
          request.post {uri:"http://#{@tvIP}:1925/1/input/key", json : json_params}, (error, response, body) ->
            #env.logger.debug(error)
            #env.logger.debug(response)
            #env.logger.debug(response.statusCode)
            
            if error isnt null
              env.logger.error(error)
            else if response.statusCode isnt 200
              throw new Error("returned #{response.statusCode}")
            else
              env.logger.debug "emitting"
              @emit 'button', b.id
              env.logger.debug "returning"
              return Promise.resolve()

      if not btn_id_found
        throw new Error("No button with the id #{buttonId} found")

  class JointspaceSourceSelection extends env.devices.ButtonsDevice
    constructor: (@config, @plugin) ->
      @name = @config.name
      @tvIP = @plugin.tvip
      @buttons = @config.buttons

      super(@config)

    destroy: () ->
      @requestPromise.cancel() if @requestPromise?
      super()

    buttonPressed: (buttonId) ->
      btn_id_found = false
      for b in @config.buttons
        if b.id is buttonId
          btn_id_found = true
          env.logger.info("Selecting Input #{b.text}")
          json_params = {id: b.command}
          request.post {uri:"http://#{@tvIP}:1925/1/sources/current", json : json_params}, (error, response, body) ->
            
            if error isnt null
              env.logger.error(error)
            else if response.statusCode isnt 200
              throw new Error("returned #{response.statusCode}")
            else
              env.logger.debug "emitting"
              @emit 'button', b.id
              env.logger.debug "returning"
              return Promise.resolve()

      if not btn_id_found
        throw new Error("No button with the id #{buttonId} found")
  

  # ###Finally
  # Create a instance of my plugin
  myPlugin = new Jointspace
  # and return it to the framework.
  return myPlugin

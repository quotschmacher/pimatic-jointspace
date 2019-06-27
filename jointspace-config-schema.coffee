# #my-plugin configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "my plugin config options"
  type: "object"
  properties:
    tvip:
      description: "IP of the TV"
      type: "string"
      default: ""
    debug:
      description: "Flag for activating debug output"
      type: "boolean"
      default: false
}